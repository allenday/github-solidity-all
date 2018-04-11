pragma solidity ^0.4.2;

contract Migrations {
  // First variable is the wallet address - set in constructor 
  address public owner;
  
  // uint = unsigned int 
  uint public last_completed_migration;

  modifier restricted() {
    if (msg.sender == owner)_;
  }

  function Migrations() {
    owner = msg.sender;
  }

  function setCompleted(uint completed) restricted {
    last_completed_migration = completed;
  }

  function upgrade(address new_address) restricted {
    Migrations upgraded = Migrations(new_address);
    upgraded.setCompleted(last_completed_migration);
  }
}
