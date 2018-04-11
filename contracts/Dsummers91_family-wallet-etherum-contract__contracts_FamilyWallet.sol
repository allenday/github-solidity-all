pragma solidity ^0.4.4;

contract FamilyWallet {
  // TYPES

  address _wallet = this; 
  Adult[] _listOfAdults;
  Child[] _listOfChildren;
  uint _allowancePeriodStart;
  uint _allowancePeriodEnd;
  uint _defaultAllowance;
  uint _duration;

  // TODO: Add _requireTasksForAllowance
  // This would require "tasksCompleted" in Child Object to be true before allowance can be paid
  // bool _requireTasksForAllowance;

  struct Child {
    uint allowance;
    address addr;
    uint allowanceDue;
    //bool tasksCompleted (will be added when  _requireTasksForAllowance is added)
  }

  struct Adult {
    address addr;
    bool approveRefund;
    uint256 balanceOf;
  }

  // EVENTS
  event MoneyReceived(uint payment, address sender);
  event AllowancePaid(uint allowance, address receiver);
  event NewAllowancePeriod(uint start, uint end);


  // MODIFIERS

  // Adult Confirmation modifier
  // Confirmation that message sender is an adult
  modifier isAdult() {
    for (uint i = 0; i < _listOfAdults.length; i++) {
      if (msg.sender == _listOfAdults[i].addr) {
        _;
      }
    }
  }

  // Child Confirmation modifier
  // Confirmation that message sender is a child
  modifier isChild() {
    for (uint i = 0; i < _listOfChildren.length; i++) {
      if (msg.sender == _listOfChildren[i].addr) {
        _;
      }
    }
  }

  // Refundable Modifier
  // Confirmation that each ADULT has approved the ability to withdraw
  // funds from the contract.
  modifier refundable() {
    for (uint i = 0; i < _listOfAdults.length; i++) {
        address adultAddress = _listOfAdults[i].addr;
        if(!getAdultByAddress(adultAddress).approveRefund) throw;
     }
     _;
  }
  // METHODS

  // Constructor Method Initialize when contract is created
  function FamilyWallet(
    address[] adults,
    address[] children,
    uint defaultAllowanceInEther,
    uint durationInDays,
    bool firstAllowancePayment // Set true if include first payment when contract created
  ) {
    // Loop through adult array and include address in mapping and array
    _defaultAllowance = defaultAllowanceInEther * 1 ether;
    for (uint j = 0; j < adults.length; j++) {
      Adult memory adult;
      adult.addr = adults[j];
      _listOfAdults.push(adult);
    }
    // Loop through children array and include address in mapping and array
    for (uint i = 0; i < children.length; i++) {
      Child memory child;
      child.addr = children[i];
      child.allowance = _defaultAllowance;
      if(firstAllowancePayment) child.allowanceDue = _defaultAllowance;
      _listOfChildren.push(child);
    }

    // Set Durations
    _allowancePeriodStart = now;
    _duration = durationInDays * 1 days;
    _allowancePeriodEnd = now + _duration;
  }


  // Make payment on allowance start,or when user calls getAllowance?
  // Right now child must call get allowance to receive alowance
  function nextAllowancePeriod(bool force) returns (bool) {
    if((now < _allowancePeriodEnd) && (!force)) throw;
    _allowancePeriodStart = _allowancePeriodEnd;
    _allowancePeriodEnd = _allowancePeriodEnd + _duration;
    for (uint i = 0; i < _listOfChildren.length; i++) {
     _listOfChildren[i].allowanceDue +=  _listOfChildren[i].allowance;
    }
    NewAllowancePeriod(_allowancePeriodStart, _allowancePeriodEnd);
    return true;
  }

  function getAllowance() isChild {
    Child memory child = getChildByAddress(msg.sender);
    if(child.allowanceDue == 0) throw;
    if(child.addr.send(child.allowanceDue)) throw;
    child.allowanceDue = 0;
    AllowancePaid(child.allowanceDue, msg.sender);
  }

  function approveRefund() isAdult {
    for (uint i = 0; i < _listOfAdults.length; i++) {
        if(msg.sender == _listOfAdults[i].addr) _listOfAdults[i].approveRefund = true;
     }
  }

  // Sends wallet balance to message sender
  // TODO:  Amount refunded should be same weighted average as amount deposited
  //        Rather that first person takes all.
  function refundBalance(address addr) isAdult refundable {
     if(getAdultByAddress(msg.sender).addr.send(_wallet.balance)) throw;
  }
  

  // Utility functions
  function getChildByAddress(address addr) internal returns (Child memory child) {
    for (uint i = 0; i < _listOfChildren.length; i++) {
      if(_listOfChildren[i].addr == addr) return _listOfChildren[i];
    }
    throw;
  }
    function getAdultByAddress(address addr) internal returns (Adult memory adult) {
    for (uint i = 0; i < _listOfAdults.length; i++) {
      return _listOfAdults[i];
    }
    throw;
  }

  // TESTING FUNCTIONS
  // NOT NECESSARY FOR DEPLOYMENTS
  function getChild(address addr) returns (address)  {
    return getChildByAddress(addr).addr;
  }

  function getAllowanceAmount(address addr) returns(uint) {
    return getChildByAddress(addr).allowanceDue;
  }

  function getChildsAmount(address addr) returns(uint) {
    return getChildByAddress(addr).allowance;
  }

  function getDefaultAllowance(string addr) returns(uint) {
    return _defaultAllowance;
  }
  
  // Fallback method, send event once money is paid
  function() payable {
    getAdultByAddress(msg.sender).balanceOf += msg.value;
    MoneyReceived(msg.value, msg.sender);
  }
// TODO:    Allow Removal of Childen/Adult
// REASON:  In case of mental/physical inability of adult 
//          to withdraw funds on his own behalf (Lost Private Key/Death)
//          Allow Remove of his account in order to be able to let other
//          adults withdraw funds. Contributions will be evenly split among
//          Other adults.
// NOTES:   Must allow a "checkin" method of some sort, if adult does not
//          check in after a period of time - allow other to vote him out
//          Otherwise if a user is checked in, there is no way he can be 
//          voted out of the family.          

}
