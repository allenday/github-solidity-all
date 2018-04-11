pragma solidity ^0.4.4;

contract AddressDemo {
  function AddressDemo() {
    // constructor
  }
  
  address owner;

  address tenant;

  function changeOwner(address newOwner) {
    owner=newOwner;
  }

  function changeTenant(address newTenant) {
    tenant = newTenant;
  }

  function getOwner() returns (address ownerAddress,uint256 balance) {
    ownerAddress = owner;
    balance = owner.balance;
  }

  function payRent(uint256 rentAmount) {
    return 0;
  }
}
