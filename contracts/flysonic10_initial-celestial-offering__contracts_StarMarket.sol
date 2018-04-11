pragma solidity ^0.4.15;

import './zeppelin/ownership/Ownable.sol';

contract StarMarket is Ownable {

// You can use this hash to verify the csv file containing all the stars
    string public csvHash = "039fdcdcfc31968c6938863ac1d293854ba810bbfa0bcd72b1f4cc2d544f3d08";

    address owner;

    string public standard = 'Stars';
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;
    uint256 public claimFee;
    uint8 public transactionFeePercentage;

    uint public nextStarIndexToAssign = 0; // TODO: unused, remove?

    bool public allStarsAssigned = false;
    bool public canClaimStars = false;
    uint public starsRemainingToAssign = 0;

//mapping (address => uint) public addressToStarIndex;
    mapping (uint => address) public starIndexToAddress;

/* This creates an array with all balances */
    mapping (address => uint256) public balanceOf;

    struct Offer {
    bool isForSale;
    uint starIndex;
    address seller;
    uint minValue;          // in ether
    address onlySellTo;     // specify to sell only to a specific person
    }

    struct Bid {
    bool hasBid;
    uint starIndex;
    address bidder;
    uint value;
    }

// A record of stars that are offered for sale at a specific minimum value, and perhaps to a specific person
    mapping (uint => Offer) public starsOfferedForSale;

// A record of the highest star bid
    mapping (uint => Bid) public starBids;

    mapping (address => uint) public pendingWithdrawals;

    event Assign(address indexed to, uint256 starIndex);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event StarTransfer(address indexed from, address indexed to, uint256 starIndex);
    event StarOffered(uint indexed starIndex, uint minValue, address indexed toAddress);
    event StarBidEntered(uint indexed starIndex, uint value, address indexed fromAddress);
    event StarBidWithdrawn(uint indexed starIndex, uint value, address indexed fromAddress);
    event StarBought(uint indexed starIndex, uint value, address indexed fromAddress, address indexed toAddress, uint256 transactionFee);
    event StarNoLongerForSale(uint indexed starIndex);
    event ClaimFeeUpdated(uint256 indexed newClaimFee);
    event TransactionFeePercentageUpdated(uint8 indexed newTransactionFeePercentage);

/* Initializes contract with initial supply tokens to the creator of the contract */
    function StarMarket() payable {
    //        balanceOf[msg.sender] = initialSupply;        // Give the creator all initial tokens
        owner = msg.sender;
        totalSupply = 119615;                               // Update total supply
        starsRemainingToAssign = totalSupply;
        name = "STARS";                                     // Set the name for display purposes
        symbol = "★";                                       // Set the symbol for display purposes
        decimals = 0;                                       // Amount of decimals for display purposes
        claimFee = 15000000000000000;                       // Price of claiming a star
        transactionFeePercentage = 5;                       // Whole number percentage (0-100)
    }

    function setInitialOwner(address to, uint starIndex, uint initialOffer) onlyOwner {
        if (allStarsAssigned && !canClaimStars) revert();
        if (starIndex >= totalSupply) revert();
        if (starIndexToAddress[starIndex] != to) {
            if (starIndexToAddress[starIndex] != 0x0) {
                balanceOf[starIndexToAddress[starIndex]]--;
            } else {
                starsRemainingToAssign--;
            }
            starIndexToAddress[starIndex] = to;
            balanceOf[to]++;
            if (initialOffer > 0) {
                offerStarForSale(starIndex, initialOffer);
            }
            Assign(to, starIndex);
        }
    }

    function setInitialOwners(address[] addresses, uint[] indices, uint[] initialOffers) onlyOwner {
        uint n = addresses.length;
        for (uint i = 0; i < n; i++) {
            setInitialOwner(addresses[i], indices[i], initialOffers[i]);
        }
    }

    function allInitialOwnersAssigned() onlyOwner {
        allStarsAssigned = true;
        canClaimStars = true;
    }

    function updateCSV(string newHash, uint256 newTotalSupply) onlyOwner {
        if (newTotalSupply < totalSupply) revert();         // We should only be able to add stars to the db
        csvHash = newHash;
        if (totalSupply != newTotalSupply) {
            starsRemainingToAssign = newTotalSupply - totalSupply;
            canClaimStars = true;
            totalSupply = newTotalSupply;
        }
    }

    function updateClaimFee(uint256 newClaimFee) onlyOwner {
        claimFee = newClaimFee;
        ClaimFeeUpdated(newClaimFee);
    }

    function updateTransactionFeePercentage(uint8 newTransactionFeePercentage) onlyOwner {
        if (newTransactionFeePercentage > 5) revert();                  // Prevent the fee from ever being more than 5%
        if (newTransactionFeePercentage < 0) revert();
        transactionFeePercentage = newTransactionFeePercentage;
        TransactionFeePercentageUpdated(newTransactionFeePercentage);
    }

    function getStar(uint starIndex) payable {
        if (!allStarsAssigned && !canClaimStars) revert();
        if (starsRemainingToAssign == 0) revert();
        if (starIndexToAddress[starIndex] != 0x0) revert();
        if (starIndex >= totalSupply) revert();
        if (msg.value < claimFee) revert();
        pendingWithdrawals[owner] += msg.value;
        starIndexToAddress[starIndex] = msg.sender;
        balanceOf[msg.sender]++;
        starsRemainingToAssign--;
        if (starsRemainingToAssign == 0) {
            canClaimStars = false;
        }
        Assign(msg.sender, starIndex);
    }

// Transfer ownership of a star to another user without requiring payment
    function transferStar(address to, uint starIndex) {
        if (!allStarsAssigned) revert();
        if (starIndexToAddress[starIndex] != msg.sender) revert();
        if (starIndex >= totalSupply) revert();
        if (starsOfferedForSale[starIndex].isForSale) {
            starNoLongerForSale(starIndex);
        }
        starIndexToAddress[starIndex] = to;
        balanceOf[msg.sender]--;
        balanceOf[to]++;
        Transfer(msg.sender, to, 1);
        StarTransfer(msg.sender, to, starIndex);
    // Check for the case where there is a bid from the new owner and refund it.
    // Any other bid can stay in place.
        Bid storage bid = starBids[starIndex];
        if (bid.bidder == to) {
        // Kill bid and refund value
            pendingWithdrawals[to] += bid.value;
            starBids[starIndex] = Bid(false, starIndex, 0x0, 0);
        }
    }

    function starNoLongerForSale(uint starIndex) {
        if (!allStarsAssigned) revert();
        if (starIndexToAddress[starIndex] != msg.sender) revert();
        if (starIndex >= totalSupply) revert();
        starsOfferedForSale[starIndex] = Offer(false, starIndex, msg.sender, 0, 0x0);
        StarNoLongerForSale(starIndex);
    }

    function offerStarForSale(uint starIndex, uint minSalePriceInWei) {
        if (!allStarsAssigned) revert();
        if (starIndexToAddress[starIndex] != msg.sender) revert();
        if (starIndex >= totalSupply) revert();
        starsOfferedForSale[starIndex] = Offer(true, starIndex, msg.sender, minSalePriceInWei, 0x0);
        StarOffered(starIndex, minSalePriceInWei, 0x0);
    }

    function offerStarForSaleToAddress(uint starIndex, uint minSalePriceInWei, address toAddress) {
        if (!allStarsAssigned) revert();
        if (starIndexToAddress[starIndex] != msg.sender) revert();
        if (starIndex >= totalSupply) revert();
        starsOfferedForSale[starIndex] = Offer(true, starIndex, msg.sender, minSalePriceInWei, toAddress);
        StarOffered(starIndex, minSalePriceInWei, toAddress);
    }

    function buyStar(uint starIndex) payable {
        if (!allStarsAssigned) revert();
        Offer storage offer = starsOfferedForSale[starIndex];
        if (starIndex >= totalSupply) revert();
        if (!offer.isForSale) revert();                // star not actually for sale
        if (offer.onlySellTo != 0x0 && offer.onlySellTo != msg.sender) revert();  // star not supposed to be sold to this user
        if (msg.value < offer.minValue) revert();      // Didn't send enough ETH
        if (offer.seller != starIndexToAddress[starIndex]) revert(); // Seller no longer owner of star

        address seller = offer.seller;

        starIndexToAddress[starIndex] = msg.sender;
        balanceOf[seller]--;
        balanceOf[msg.sender]++;
        Transfer(seller, msg.sender, 1);

        starNoLongerForSale(starIndex);
        uint256 transactionFee = msg.value * (transactionFeePercentage / 100);
        uint256 toSeller = msg.value - transactionFee;
        pendingWithdrawals[owner] += transactionFee;
        pendingWithdrawals[seller] += toSeller;
        StarBought(starIndex, msg.value, seller, msg.sender, transactionFee);

    // Check for the case where there is a bid from the new owner and refund it.
    // Any other bid can stay in place.
        Bid storage bid = starBids[starIndex];
        if (bid.bidder == msg.sender) {
        // Kill bid and refund value
            pendingWithdrawals[msg.sender] += bid.value;
            starBids[starIndex] = Bid(false, starIndex, 0x0, 0);
        }
    }

    function withdraw() {
        if (!allStarsAssigned) revert();
        uint amount = pendingWithdrawals[msg.sender];
    // Remember to zero the pending refund before
    // sending to prevent re-entrancy attacks
        pendingWithdrawals[msg.sender] = 0;
        msg.sender.transfer(amount);
    }

    function enterBidForStar(uint starIndex) payable {
        if (starIndex >= totalSupply) revert();
        if (!allStarsAssigned) revert();
        if (starIndexToAddress[starIndex] == 0x0) revert();
        if (starIndexToAddress[starIndex] == msg.sender) revert();
        if (msg.value == 0) revert();
        Bid storage existing = starBids[starIndex];
        if (msg.value <= existing.value) revert();
        if (existing.value > 0) {
        // Refund the failing bid
            pendingWithdrawals[existing.bidder] += existing.value;
        }
        starBids[starIndex] = Bid(true, starIndex, msg.sender, msg.value);
        StarBidEntered(starIndex, msg.value, msg.sender);
    }

    function acceptBidForStar(uint starIndex, uint minPrice) {
        if (starIndex >= totalSupply) revert();
        if (!allStarsAssigned) revert();
        if (starIndexToAddress[starIndex] != msg.sender) revert();
        address seller = msg.sender;
        Bid storage bid = starBids[starIndex];
        if (bid.value == 0) revert();
        if (bid.value < minPrice) revert();

        starIndexToAddress[starIndex] = bid.bidder;
        balanceOf[seller]--;
        balanceOf[bid.bidder]++;
        Transfer(seller, bid.bidder, 1);

        starsOfferedForSale[starIndex] = Offer(false, starIndex, bid.bidder, 0, 0x0);
        uint256 transactionFee = bid.value * (transactionFeePercentage / 100);
        uint256 toSeller = bid.value - transactionFee;
        starBids[starIndex] = Bid(false, starIndex, 0x0, 0);
        pendingWithdrawals[owner] += transactionFee;
        pendingWithdrawals[seller] += toSeller;
        StarBought(starIndex, bid.value, seller, bid.bidder, transactionFee);
    }

    function withdrawBidForStar(uint starIndex) {
        if (starIndex >= totalSupply) revert();
        if (!allStarsAssigned) revert();
        if (starIndexToAddress[starIndex] == 0x0) revert();
        if (starIndexToAddress[starIndex] == msg.sender) revert();
        Bid storage bid = starBids[starIndex];
        if (bid.bidder != msg.sender) revert();
        StarBidWithdrawn(starIndex, bid.value, msg.sender);
        uint amount = bid.value;
        starBids[starIndex] = Bid(false, starIndex, 0x0, 0);
    // Refund the bid money
        msg.sender.transfer(amount);
    }

}