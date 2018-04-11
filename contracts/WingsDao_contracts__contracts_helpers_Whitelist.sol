pragma solidity ^0.4.2;

contract Whitelist {
  /*
    List of whitelisted users/contracts who can modificate storage
  */
  mapping(address => bool) whitelist;

  /*
    Allow to do something if address inside whitelist
  */
  modifier allowedAccess() {
    if (whitelist[msg.sender] == true) {
      _;
    }
  }

  /*
    Constructor.
    Set creator as first allowed address.
  */
  function Whitelist() {
    whitelist[msg.sender] = true;
  }

  /*
    Add address to whitelist
  */
  function addMember(address writer) allowedAccess {
    if (writer != address(0)) {
      whitelist[writer] = true;
    }
  }
}
