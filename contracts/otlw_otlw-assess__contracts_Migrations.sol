pragma solidity ^0.4.4;

contract Migrations {
  address public member;
  uint public last_completed_migration;

  modifier restricted() {
    if (msg.sender == member) _;
  }

  function Migrations() public {
    member = msg.sender;
  }

  function setCompleted(uint completed) public restricted {
    last_completed_migration = completed;
  }

  function upgrade(address new_address) public restricted {
    Migrations upgraded = Migrations(new_address);
    upgraded.setCompleted(last_completed_migration);
  }
}
