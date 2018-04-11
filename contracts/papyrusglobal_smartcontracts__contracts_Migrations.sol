pragma solidity ^0.4.11;

import "./common/SafeOwnable.sol";

/**
 * @title Migrations
 * @dev This is a truffle contract, needed for truffle integration.
 */
contract Migrations is SafeOwnable {
  
  // PUBLIC FUNCTIONS

  function setCompleted(uint256 completed) public onlyOwner {
    lastCompletedMigration = completed;
  }

  function upgrade(address newAddress) public onlyOwner {
    Migrations upgraded = Migrations(newAddress);
    upgraded.setCompleted(lastCompletedMigration);
  }
  
  // FIELDS

  uint256 public lastCompletedMigration;
}
