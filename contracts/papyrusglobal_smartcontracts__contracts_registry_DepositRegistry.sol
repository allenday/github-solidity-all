pragma solidity ^0.4.18;


// This is the base contract that your contract DepositRegistry extends from.
contract DepositRegistry {

  // This is the function that actually insert a record.
  function register(address key, uint256 amount, address depositOwner) public;

  // Unregister a given record
  function unregister(address key) public;

  function transfer(address key, address newOwner, address sender) public;

  function spend(address key, uint256 amount) public;

  function refill(address key, uint256 amount) public;

  // Tells whether a given key is registered.
  function isRegistered(address key) public view returns (bool);

  function getDepositOwner(address key) public view returns (address);

  function getDeposit(address key) public view returns (uint256 amount);

  function getDepositRecord(address key) public view returns (address owner, uint256 time, uint256 amount, address depositOwner);

  function hasEnough(address key, uint256 amount) public view returns (bool);

  function kill() public;
}
