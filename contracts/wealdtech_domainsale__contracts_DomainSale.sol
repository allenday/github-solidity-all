pragma solidity ^0.4.2;

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import "node_modules/wealdtech-solidity/contracts/ens/ENSReverseRegister.sol";
import "node_modules/wealdtech-solidity/contracts/math/SafeMath.sol";
import "node_modules/wealdtech-solidity/contracts/auth/Permissioned.sol";
import "node_modules/wealdtech-solidity/contracts/lifecycle/Pausable.sol";

// Interesting parts of the ENS deed
contract Deed {
    address public owner;
    address public previousOwner;
}

// Interesting parts of the ENS registry
contract Registry {
    function owner(bytes32 _hash) public constant returns (address);
}

// Interesting parts of the ENS registrar
contract Registrar {
    function transfer(bytes32 _hash, address newOwner) public;
    function entries(bytes32 _hash) public constant returns (uint, Deed, uint, uint, uint);
}

contract DomainSale is ENSReverseRegister, Pausable {
    using SafeMath for uint256;

    Registrar public registrar;
    mapping (string => Sale) private sales;
    mapping (address => uint256) private balances;

    // Auction parameters
    uint256 private constant AUCTION_DURATION = 24 hours;
    uint256 private constant HIGH_BID_KICKIN = 7 days;
    uint256 private constant NORMAL_BID_INCREASE_PERCENTAGE = 10;
    uint256 private constant HIGH_BID_INCREASE_PERCENTAGE = 50;

    // Distribution of the sale funds
    uint256 private constant SELLER_SALE_PERCENTAGE = 90;
    uint256 private constant START_REFERRER_SALE_PERCENTAGE = 5;
    uint256 private constant BID_REFERRER_SALE_PERCENTAGE = 5;

    // ENS
    string private constant CONTRACT_ENS = "domainsale.eth";
    // Hex is namehash("eth")
    bytes32 private constant NAMEHASH_ETH = 0x93cdeb708b7545dc668eb9280176169d1c33cfd8ed6f04690a0bcc88a93fc4ae;

    struct Sale {
        // The lowest direct purchase price that will be accepted
        uint256 price;
        // The lowest auction bid that will be accepted
        uint256 reserve;
        // The last bid on the auction.  0 if no bid has been made
        uint256 lastBid;
        // The address of the last bider on the auction.  0 if no bid has been made
        address lastBidder;
        // The timestamp when this auction started
        uint256 auctionStarted;
        // The timestamp at which this auction ends
        uint256 auctionEnds;
        // The address of the referrer who started the sale
        address startReferrer;
        // The address of the referrer who supplied the winning bid
        address bidReferrer;
    }

    //
    // Events
    //

    // Sent when a name is offered (can occur multiple times if the seller
    // changes their prices)
    event Offer(address indexed seller, string name, uint256 price, uint256 reserve);
    // Sent when a bid is placed for a name
    event Bid(address indexed bidder, string name, uint256 bid);
    // Sent when a name is transferred to a new owner
    event Transfer(address indexed seller, address indexed buyer, string name, uint256 value);
    // Sent when a sale for a name is cancelled
    event Cancel(string name);
    // Sent when funds are withdrawn
    event Withdraw(address indexed recipient, uint256 amount);

    //
    // Modifiers
    //

    // Actions that can only be undertaken by the seller of the name.
    // The owner of the name is this contract, so we use the previous
    // owner from the deed
    modifier onlyNameSeller(string _name) {
        Deed deed;
        (,deed,,,) = registrar.entries(keccak256(_name));
        require(deed.owner() == address(this));
        require(deed.previousOwner() == msg.sender);
        _;
    }

    // It is possible for a name to be invalidated, in which case the
    // owner will be reset
    modifier deedValid(string _name) {
        address deed;
        (,deed,,,) = registrar.entries(keccak256(_name));
        require(deed != 0);
        _;
    }

    // Actions that can only be undertaken if the name sale has attracted
    // no bids.
    modifier auctionNotStarted(string _name) {
        require(sales[_name].auctionStarted == 0);
        _;
    }

    // Allow if the name can be bid upon
    modifier canBid(string _name) {
        require(sales[_name].reserve != 0);
        _;
    }

    // Allow if the name can be purchased
    modifier canBuy(string _name) {
        require(sales[_name].price != 0);
        _;
    }

    /**
     * @dev Constructor takes the address of the ENS registry
     */
    function DomainSale(address _registry) public ENSReverseRegister(_registry, CONTRACT_ENS) {
        registrar = Registrar(Registry(_registry).owner(NAMEHASH_ETH));
    }

    //
    // Accessors for sales struct
    //

    /**
     * @dev return useful information from the sale structure in one go
     */
    function sale(string _name) public constant returns (uint256, uint256, uint256, address, uint256, uint256) {
        Sale storage s = sales[_name];
        return (s.price, s.reserve, s.lastBid, s.lastBidder, s.auctionStarted, s.auctionEnds);
    }

    /**
     * @dev a flag set if this name can be purchased through auction
     */
    function isAuction(string _name) public constant returns (bool) {
        return sales[_name].reserve != 0;
    }

    /**
     * @dev a flag set if this name can be purchased outright
     */
    function isBuyable(string _name) public constant returns (bool) {
        return sales[_name].price != 0 && sales[_name].auctionStarted == 0;
    }

    /**
     * @dev a flag set if the auction has started
     */
    function auctionStarted(string _name) public constant returns (bool) {
        return sales[_name].lastBid != 0;
    }

    /**
     * @dev the time at which the auction ends
     */
    function auctionEnds(string _name) public constant returns (uint256) {
        return sales[_name].auctionEnds;
    }

    /**
     * @dev minimumBid is the greater of the minimum bid or the last bid + 10%.
     *      If an auction has been going longer than 7 days then it is the last
     *      bid + 50%.
     */
    function minimumBid(string _name) public constant returns (uint256) {
        Sale storage s = sales[_name];

        if (s.auctionStarted == 0) {
            return s.reserve;
        } else if (s.auctionStarted.add(HIGH_BID_KICKIN) > now) {
            return s.lastBid.add(s.lastBid.mul(NORMAL_BID_INCREASE_PERCENTAGE).div(100));
        } else {
            return s.lastBid.add(s.lastBid.mul(HIGH_BID_INCREASE_PERCENTAGE).div(100));
        }
    }

    /**
     * @dev price is the instant purchase price.
     */
    function price(string _name) public constant returns (uint256) {
        return sales[_name].price;
    }

    /**
     * @dev The balance available for withdrawal
     */
    function balance(address addr) public constant returns (uint256) {
        return balances[addr];
    }

    //
    // Operations
    //

    /**
     * @dev offer a domain for sale.
     *      The price is the price at which a domain can be purchased directly.
     *      The reserve is the initial lowest price for which a bid can be made.
     */
    function offer(string _name, uint256 _price, uint256 reserve, address referrer) onlyNameSeller(_name) auctionNotStarted(_name) deedValid(_name) ifNotPaused public {
        require(_price == 0 || _price > reserve);
        require(_price != 0 || reserve != 0);
        Sale storage s = sales[_name];
        s.reserve = reserve;
        s.price = _price;
        s.startReferrer = referrer;
        Offer(msg.sender, _name, _price, reserve);
    }

    /**
     * @dev cancel a sale for a domain.
     *      This can only happen if there have been no bids for the name.
     */
    function cancel(string _name) onlyNameSeller(_name) auctionNotStarted(_name) deedValid(_name) ifNotPaused public {
        // Finished with the sale information
        delete sales[_name];

        registrar.transfer(keccak256(_name), msg.sender);
        Cancel(_name);
    }

    /**
     * @dev buy a domain directly
     */
    function buy(string _name, address bidReferrer) canBuy(_name) deedValid(_name) ifNotPaused public payable {
        Sale storage s = sales[_name];
        require(msg.value >= s.price);
        require(s.auctionStarted == 0);

        // Obtain the previous owner from the deed
        Deed deed;
        (,deed,,,) = registrar.entries(keccak256(_name));
        address previousOwner = deed.previousOwner();

        // Transfer the name
        registrar.transfer(keccak256(_name), msg.sender);
        Transfer(previousOwner, msg.sender, _name, msg.value);

        // Distribute funds to referrers
        distributeFunds(msg.value, previousOwner, s.startReferrer, bidReferrer);

        // Finished with the sale information
        delete sales[_name];

        // As we're here, return any funds that the sender is owed
        withdraw();
    }

    /**
     * @dev bid for a domain
     */
    function bid(string _name, address bidReferrer) canBid(_name) deedValid(_name) ifNotPaused public payable {
        require(msg.value >= minimumBid(_name));

        Sale storage s = sales[_name];
        require(s.auctionStarted == 0 || now < s.auctionEnds);

        if (s.auctionStarted == 0) {
          // First bid; set the auction start
          s.auctionStarted = now;
        } else {
          // Update the balance for the outbid bidder
          balances[s.lastBidder] = balances[s.lastBidder].add(s.lastBid);
        }
        s.lastBidder = msg.sender;
        s.lastBid = msg.value;
        s.auctionEnds = now.add(AUCTION_DURATION);
        s.bidReferrer = bidReferrer;
        Bid(msg.sender, _name, msg.value);

        // As we're here, return any funds that the sender is owed
        withdraw();
    }

    /**
     * @dev finish an auction
     */
    function finish(string _name) deedValid(_name) ifNotPaused public {
        Sale storage s = sales[_name];
        require(now > s.auctionEnds);

        // Obtain the previous owner from the deed
        Deed deed;
        (,deed,,,) = registrar.entries(keccak256(_name));

        address previousOwner = deed.previousOwner();
        registrar.transfer(keccak256(_name), s.lastBidder);
        Transfer(previousOwner, s.lastBidder, _name, s.lastBid);

        // Distribute funds to referrers
        distributeFunds(s.lastBid, previousOwner, s.startReferrer, s.bidReferrer);

        // Finished with the sale information
        delete sales[_name];

        // As we're here, return any funds that the sender is owed
        withdraw();
    }

    /**
     * @dev withdraw any owned balance
     */
    function withdraw() ifNotPaused public {
        uint256 amount = balances[msg.sender];
        if (amount > 0) {
            balances[msg.sender] = 0;
            msg.sender.transfer(amount);
            Withdraw(msg.sender, amount);
        }
    }

    /**
     * @dev Invalidate an auction if the deed is no longer active
     */
    function invalidate(string _name) ifNotPaused public {
        // Ensure the deed has been invalidated
        address deed;
        (,deed,,,) = registrar.entries(keccak256(_name));
        require(deed == 0);

        Sale storage s = sales[_name];

        // Update the balance for the winning bidder
        balances[s.lastBidder] = balances[s.lastBidder].add(s.lastBid);

        // Finished with the sale information
        delete sales[_name];

        // Cancel the auction
        Cancel(_name);

        // As we're here, return any funds that the sender is owed
        withdraw();
    }

    //
    // Internal functions
    //

    /**
     * @dev Distribute funds for a sale to the relevant parties
     */
    function distributeFunds(uint256 amount, address seller, address startReferrer, address bidReferrer) internal {
        uint256 startReferrerFunds = amount.mul(START_REFERRER_SALE_PERCENTAGE).div(100);
        balances[startReferrer] = balances[startReferrer].add(startReferrerFunds);
        uint256 bidReferrerFunds = amount.mul(BID_REFERRER_SALE_PERCENTAGE).div(100);
        balances[bidReferrer] = balances[bidReferrer].add(bidReferrerFunds);
        uint256 sellerFunds = amount.sub(startReferrerFunds).sub(bidReferrerFunds);
        balances[seller] = balances[seller].add(sellerFunds);
    }
}
