// https://remix.ethereum.org
// https://github.com/truffle-box/react-box/blob/master/contracts/Migrations.sol
// Migrations.upgrade won't work · Issue #216 · trufflesuite/truffle 
// https://github.com/trufflesuite/truffle/issues/216

pragma solidity ^0.4.14;

contract Migrations {
  address public owner;
  uint public last_completed_migration;

  modifier restricted() {
    if (msg.sender == owner) _;
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

// require
contract Migrations2 {
  address public owner;
  uint public last_completed_migration;

  modifier restricted() {
    // throw 
    require (msg.sender == owner);
    _;
  }

  function Migrations2() {
    owner = msg.sender;
  }

  function setCompleted(uint completed) restricted {
    last_completed_migration = completed;
  }

  function upgrade(address new_address) restricted {
    Migrations2 upgraded = Migrations2(new_address);
    upgraded.setCompleted(last_completed_migration);
  }
}

// setNewOwner() ? 
// migrationOld own migrationNew ?
contract Migrations3 {
  address public owner;
  uint public last_completed_migration;

  modifier restricted() {
    require (msg.sender == owner);
    _;
  }

  function Migrations3() {
    owner = msg.sender;
  }
  
  function setOwner(address _owner) restricted {
     owner = _owner;
  }

  function setCompleted(uint completed) restricted {
    last_completed_migration = completed;
  }

  function upgrade(address new_address) restricted {
    Migrations3 upgraded = Migrations3(new_address);
    upgraded.setCompleted(last_completed_migration);
  }
  
}

//
// M1, M2
// M1.setCompleted(9)
// M2.setOwner(M1.address)
// M1.upgrade(M2.address)
// M2.last_completed_migration()
// M1.setUpgradedOwner(M2.address, account0)
// M2.setCompleted(19)
//

contract Migrations4 {
  address public owner;
  uint public last_completed_migration;

  modifier restricted() {
    require (msg.sender == owner);
    _;
  }

  function Migrations4() {
    owner = msg.sender;
  }
  
  function setOwner(address _owner) restricted {
     owner = _owner;
  }
  
  function setUpgradedOwner(address new_address, address _owner) restricted {
     Migrations4 upgraded = Migrations4(new_address);
     upgraded.setOwner(_owner);
  }

  function setCompleted(uint completed) restricted {
    last_completed_migration = completed;
  }

  function upgrade(address new_address) restricted {
    Migrations4 upgraded = Migrations4(new_address);
    upgraded.setCompleted(last_completed_migration);
  }
  
}