pragma solidity ^0.4.11;

import "./zeppelin/math/SafeMath.sol";
import "./zeppelin/ownership/Ownable.sol";

contract EZEtherMarketplace is Ownable {
  using SafeMath for uint;

  event OrderAdded(string uid, address seller, address buyer, uint amount, uint price, string currency);
  event OrderCompleted(string uid, address seller, address buyer, uint amount);
  event DisputeResolved(string uid, address seller, address buyer, string resolvedTo);
  event OrderDisputed(address seller, string uid, address buyer);

  mapping(address => address) private specialFeeRecipient;
  mapping(address => uint256) private specialFeeRates;
  mapping(address => uint) private specialMinimumAmounts;
  mapping(address => uint) private specialMaximumAmounts;
  mapping(address => mapping(string => Order)) private orders;
  address public disputeResolver;
  address public disputeInterface;
  address public feeRecipient;
  uint public feePercent;
  uint public minimumAmount;
  uint public maximumAmount;

  enum Status { None, Open, Complete, Disputed, ResolvedSeller, ResolvedBuyer }

  struct Order {
    address buyer;
    uint amount;
    uint fee;
    Status status;
  }

  modifier onlyDisputeInterface {
    require(msg.sender == disputeInterface);
    _;
  }

  function EZEtherMarketplace() {
     minimumAmount = 0.0001 ether;
     maximumAmount = 5 ether;
     feePercent = 100; //1%
  }

  function addOrder(string uid, address buyer, uint _amount, uint price, string currency, address advertiser) payable external {
    require(!isContract(msg.sender));
    uint fee = calculateFee(_amount, msg.sender);

    if(advertiser == msg.sender) {
      require(msg.value == (_amount + fee));
    } else {
      require(msg.value == _amount);
    }

    require(
      (!isContract(buyer)) &&
      (_amount >= getMinAmount(msg.sender)) &&
      (_amount <= getMaxAmount(msg.sender)) &&
      (orders[msg.sender][uid].status == Status.None)
      );

    orders[msg.sender][uid].buyer = buyer;
    if(advertiser == msg.sender) {
      orders[msg.sender][uid].amount = _amount;
    } else {
      orders[msg.sender][uid].amount = _amount - fee;
    }
    orders[msg.sender][uid].fee = fee;
    orders[msg.sender][uid].status = Status.Open;

    OrderAdded(uid, msg.sender, buyer, _amount, price, currency);
  }

  function completeOrder(string uid) external {
    require(
      (orders[msg.sender][uid].status == Status.Open || orders[msg.sender][uid].status == Status.Disputed)
    );

    orders[msg.sender][uid].buyer.transfer(orders[msg.sender][uid].amount);
    getFeeRecipient(msg.sender).transfer(orders[msg.sender][uid].fee);

    if(orders[msg.sender][uid].status == Status.Open) {
      orders[msg.sender][uid].status = Status.Complete;
      OrderCompleted(uid, msg.sender, orders[msg.sender][uid].buyer, orders[msg.sender][uid].amount);
    } else {
      orders[msg.sender][uid].status = Status.ResolvedBuyer;
      DisputeResolved(uid, msg.sender, orders[msg.sender][uid].buyer, 'buyer');
    }
  }

  function setDisputed(address seller, string uid) onlyDisputeInterface external {
    require(orders[seller][uid].status == Status.Open);
    orders[seller][uid].status = Status.Disputed;
    OrderDisputed(seller, uid, orders[seller][uid].buyer);
  }

  function resolveDisputeBuyer(address seller, string uid) onlyDisputeInterface external {
    require(orders[seller][uid].status == Status.Disputed);
    orders[seller][uid].buyer.transfer(orders[seller][uid].amount);
    getFeeRecipient(seller).transfer(orders[seller][uid].fee);
    orders[seller][uid].status = Status.ResolvedBuyer;
    DisputeResolved(uid, seller, orders[seller][uid].buyer, 'buyer');
  }

  function resolveDisputeSeller(address seller, string uid) onlyDisputeInterface external {
    require(orders[seller][uid].status == Status.Disputed);
    seller.transfer(orders[seller][uid].amount.add(orders[seller][uid].fee));
    orders[seller][uid].status = Status.ResolvedSeller;
    DisputeResolved(uid, seller, orders[seller][uid].buyer, 'seller');
  }

  function setDisputeInterface(address _disputeInterface) onlyOwner external {
     disputeInterface = _disputeInterface;
  }

  function setDisputeResolver(address _disputeResolver) onlyOwner external {
     disputeResolver = _disputeResolver;
  }

  function setFeeRecipient(address _feeRecipient) onlyOwner external {
     feeRecipient = _feeRecipient;
  }

  function setFeePercent(uint _feePercent) onlyOwner external {
     feePercent = _feePercent;
  }

  function setSpecialFeePercent(address seller, uint _feePercent) onlyOwner external {
     specialFeeRates[seller] = _feePercent;
  }

  function setSpecialLimits(address seller, uint min, uint max) onlyOwner external {
    require(min < max);
    specialMinimumAmounts[seller] = min;
    specialMaximumAmounts[seller] = max;
  }

  function setLimits(uint min, uint max) onlyOwner external {
    require(min < max);
    minimumAmount = min;
    maximumAmount = max;
  }


  function getFeeRecipient(address seller) internal constant returns (address) {
    if(specialFeeRecipient[seller] != address(0)) {
      return specialFeeRecipient[seller];
    }
    return feeRecipient;
  }

  function getFeePercent(address seller) internal constant returns (uint) {
    if(specialFeeRates[seller] > 0) {
      return specialFeeRates[seller];
    }
    return feePercent;
  }

  function getFeePercent() external constant returns (uint) {
    if(specialFeeRates[msg.sender] > 0) {
      return specialFeeRates[msg.sender];
    }
    return feePercent;
  }

  function getMinAmount() external constant returns (uint) {
    if(specialMinimumAmounts[msg.sender] > 0) {
      return specialMinimumAmounts[msg.sender];
    }
    return minimumAmount;
  }

  function getMaxAmount() external constant returns (uint) {
    if(specialMaximumAmounts[msg.sender] > 0) {
      return specialMaximumAmounts[msg.sender];
    }
    return maximumAmount;
  }

  function getMinAmount(address seller) internal constant returns (uint) {
    if(specialMinimumAmounts[seller] > 0) {
      return specialMinimumAmounts[seller];
    }
    return minimumAmount;
  }

  function getMaxAmount(address seller) internal constant returns (uint) {
    if(specialMaximumAmounts[seller] > 0) {
      return specialMaximumAmounts[seller];
    }
    return maximumAmount;
  }

  function calculateFee(uint amount, address seller) internal returns (uint) {
    //((amount * 100) * feePercent) / 10000
    return ((amount.mul(100)).mul(getFeePercent(seller))).div(1000000);
  }

  function isContract(address addr) internal returns (bool) {
    uint size;
    assembly { size := extcodesize(addr) }
    return size > 0;
  }

}
