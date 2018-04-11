pragma solidity ^0.4.4;

contract Ownership {
  function Ownership() public {
    // constructor
    owner = msg.sender;
  }

  mapping (uint=>address) rtoMap;

  address[] rtoList;
  
  address owner;

  function addRTO(uint id, address rtoAddress) internal {
    rtoMap[id] = rtoAddress;
    rtoList.push(rtoAddress);
  }

  modifier onlyOwner() {
    if (owner == msg.sender) {
      _;
    } else {
      revert();
    }
  }

  modifier onlyRTO() {
    _;
  }

  modifier onlyOwnerOrRTO() {
    _;
  }

  function changeOwner(address newOwner) public onlyRTO {
    owner = newOwner;
  }
}
