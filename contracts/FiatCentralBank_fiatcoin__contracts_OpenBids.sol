pragma solidity ^0.4.13;

import './math/SafeMath.sol';
import './time/Clock.sol';
import './FiatBase.sol';
import './ownership/Ownable.sol';
import './LibSort.sol';



contract OpenBids is Ownable {
  using SafeMath for uint256;

  // beware: constant is not enforced
  uint constant uintMAX = 2**256-1;

  struct Bid {
    address bidder;
    uint fiat; // amount of FTCs/fiat
    uint rate; // FTC/ETH rate paid. how much fiat is 1 ether
    uint deposit; // total ETH amount paid = fiat*rate
    bool isWinner;
    uint next;  // linked list: next item
    uint previous; // linked list: previous item
  }

  struct DoublyLinkedList {
   Bid[] list; // why can I not include the 'storage' identifier?
   uint head;
   uint tail;
  }

  struct BidderAllowance {
    uint fiat;
    uint eth;
  }

  mapping(address => uint[]) public bidsMap;
  address[] addressList;
  DoublyLinkedList bids;

  mapping(address => BidderAllowance) public biddersAllowances;

  // Parameters of the auction. Times are either
  // absolute unix timestamps (seconds since 1970-01-01)
  // or time periods in seconds.
  FiatBase fiatcoin;
  LibSort libsort;
  address public beneficiary;
  uint public auctionStart;
  uint public biddingTime;
  uint public minimumEth;
  // the FTC funds for this bid.
  // fiatcoin.balanceOf(this) should be at least this amount
  uint public amountFiat;
  uint public cummulativeBidFiat;
  uint public finalRate;
  bool public ended;

  // Clock object, abstracted in order to enable testing
  Clock public clock;

  // Events that will be fired on changes.
  event NewBid(address bidder, uint fiat, uint rate, uint deposit);
  event AuctionEnded(uint ftcEthRate);
  event AnnounceWinner(address winner, uint fiat);
  event SetAllowance(uint fiatBidAllowance, uint etherBidAllowance, uint bidDeposit);

  // The following is a so-called natspec comment,
  // recognizable by the three slashes.
  // It will be shown when the user is asked to
  // confirm a transaction.

  /// Create a simple auction with `_biddingTime`
  /// seconds bidding time on behalf of the
  /// beneficiary address `_beneficiary`.
  function OpenBids(
      address _fiatcoin,
      uint _biddingTime,
      address _beneficiary,
      address _clock,
      uint _minimumEth,
      uint _amountFiat
  ) {
      // interpret this address as a FiatBase contract instances
      fiatcoin = FiatBase(_fiatcoin);
      libsort = new LibSort();
      beneficiary = _beneficiary;
      biddingTime = _biddingTime;
      clock = Clock(_clock);
      uint time_now = clock.get_time();
      auctionStart = time_now;
      minimumEth = _minimumEth;
      amountFiat = _amountFiat;
      cummulativeBidFiat = 0;
      finalRate = 0;
      ended = false;
  }

  function getBidsLength() returns (uint256) {
    return bids.list.length;
  }

  //function getBid(uint index) returns (address bidder, uint fiat, uint rate, uint deposit, bool isWinner, uint next, uint previous) {
  function getBid(uint index) returns (uint previous) {
    require(index <= bids.list.length);
    Bid b = bids.list[index];
    return (b.previous);
  }

  function searchAddress(address addr) internal returns (bool) {
    bool ret = false;
    for (uint i = 0; i < addressList.length; i++) {
      if (addr == addressList[i]) {
        ret = true;
        break;
      }
    }
    return ret;
  }


  /// Bid on the auction with the value sent
  /// together with this transaction.
  /// The value will only be refunded if the
  /// auction is not won.
  function bid(uint _fiat) payable {
      require(minimumEth <= msg.value);
      uint balanceThis = fiatcoin.balanceOf(this);
      require(amountFiat <= balanceThis);
      require(false == ended);
      uint time_now = clock.get_time();
      // The keyword payable
      // is required for the function to
      // be able to receive Ether.

      require(time_now >= auctionStart );
      // Revert the call if the bidding
      // period is over.
      require(time_now <= (auctionStart + biddingTime));

      uint _rate = SafeMath.div(SafeMath.mul(1 ether, _fiat), msg.value);
      require(_rate > 0);

      if (!searchAddress(msg.sender)) {
        addressList.push(msg.sender);
      }
      uint bidIndex = bids.list.push(Bid({
          bidder: msg.sender,
          fiat: _fiat,
          rate: _rate,
          deposit: msg.value,
          isWinner: false,
          next: uintMAX,
          previous: bids.list.length - 1
      })) - 1;
      if (bidIndex > 0) {
        bids.list[bidIndex -1].next = bidIndex;
      }
      else {
        bids.list[bidIndex].previous = uintMAX;
      }
      bids.tail = bids.list.length - 1;
      bidsMap[msg.sender].push(bidIndex);
      cummulativeBidFiat += _fiat;
      NewBid(msg.sender, _fiat, _rate, msg.value);
  }

  // orders first by rate (low to high) and second by fiat amount (high to low)
  function quickSortBids() internal onlyOwner {
    libsort.reset();
    for (uint i = 0; i < bids.list.length; i++) {
      libsort.push(i, bids.list[i].fiat);
    }
    libsort.sort(true); // sort by fiat (high to low)
    uint idx;
    uint vl;
    for (i = 0; i < bids.list.length; i++) {
      (idx, vl) = libsort.get(i);
      libsort.setValue(i, bids.list[idx].rate);
    }
    libsort.sort(false); // sort by rate (low to high)
    // create copy of bids
    Bid[] memory copy = new Bid[](bids.list.length);
    for (i = 0; i < bids.list.length; i++) {
      copy[i] = bids.list[i];
    }
    // copy ordered bids
    for (i = 0; i < bids.list.length; i++) {
      (idx, vl) = libsort.get(i);
      bids.list[i] = copy[idx];
    }
  }

  // sets winners and returns FTC/ETH rate
  function calculateWinners() internal onlyOwner returns (uint)  {
    uint maximumRateBid = 0; // maximum FTC/ETH (cheapest fiat)
    // if there was a lack of bids, all bidders are winners
    if (cummulativeBidFiat <= amountFiat) {
      if (bids.list.length > 0) {
        maximumRateBid = bids.list[0].rate;
        for (uint i = 0; i < bids.list.length; i++) {
          bids.list[i].isWinner = true;
          AnnounceWinner(bids.list[i].bidder, bids.list[i].fiat);
          if (bids.list[i].rate > maximumRateBid) {
            maximumRateBid = bids.list[i].rate;
          }
        }
      }
    }
    // there are more bids than necessary, some bidders won't win
    else {
      quickSortBids();
      uint accumulatedFiatFinal = 0;
      if (bids.list.length > 0) {
        uint index = bids.head;
        maximumRateBid = bids.list[index].rate;
        while (accumulatedFiatFinal < amountFiat &&
               index < bids.list.length) {
          accumulatedFiatFinal += bids.list[index].fiat;
          if (maximumRateBid < bids.list[index].rate) {
             maximumRateBid = bids.list[index].rate;
          }
          bids.list[index].isWinner = true;
          AnnounceWinner(bids.list[index].bidder, bids.list[index].fiat);
          index = bids.list[index].next;
        }
      }
    }
    return maximumRateBid;
  }

  function setAllowances() internal onlyOwner  {
    if (bids.list.length > 0) {
      uint index = bids.head;
      uint accumulatedFiatFinal = 0;
      uint fiatBalance = fiatcoin.balanceOf(this);
      while (accumulatedFiatFinal < amountFiat &&
             index < bids.list.length) {
        Bid memory bid = bids.list[index];
        if (true == bid.isWinner) {
          uint fiatBidAllowance = 0;
          if (accumulatedFiatFinal + bid.fiat > fiatBalance) {
            fiatBidAllowance = fiatBalance - accumulatedFiatFinal;
          } else {
            fiatBidAllowance += bid.fiat;
          }
          biddersAllowances[bid.bidder].fiat += fiatBidAllowance;
          accumulatedFiatFinal += fiatBidAllowance;
          uint etherBidAllowance = 
            bid.deposit -
            SafeMath.div(SafeMath.mul(1 ether, fiatBidAllowance), finalRate);
          biddersAllowances[bid.bidder].eth += etherBidAllowance;
          SetAllowance(fiatBidAllowance, etherBidAllowance, bid.deposit);
        }
        // not a winner, return all ether sent
        else {
          biddersAllowances[bid.bidder].eth += bid.deposit;
        }
        index = bid.next;
      }
    }
  }

  function withdraw() payable {
    require(true == ended);
    if (biddersAllowances[msg.sender].eth > 0) {
      msg.sender.transfer(biddersAllowances[msg.sender].eth);
    }
    if (biddersAllowances[msg.sender].fiat > 0) {
      fiatcoin.transfer(msg.sender, biddersAllowances[msg.sender].fiat);
    }
  }

  /// End the auction and send the highest bid
  /// to the beneficiary.
  function auctionEnd() onlyOwner {
      // It is a good guideline to structure functions that interact
      // with other contracts (i.e. they call functions or send Ether)
      // into three phases:
      // 1. checking conditions
      // 2. performing actions (potentially changing conditions)
      // 3. interacting with other contracts
      // If these phases are mixed up, the other contract could call
      // back into the current contract and modify the state or cause
      // effects (ether payout) to be performed multiple times.
      // If functions called internally include interaction with external
      // contracts, they also have to be considered interaction with
      // external contracts.

      // 1. Conditions
      // auction should have ended
      uint time_now = clock.get_time();
      require(time_now >= (auctionStart + biddingTime));
      // there should be enough FTC funds by now
      require(amountFiat <= fiatcoin.balanceOf(this));
      finalRate = calculateWinners();
      setAllowances();
      ended = true;
      AuctionEnded(finalRate); 
  }
}