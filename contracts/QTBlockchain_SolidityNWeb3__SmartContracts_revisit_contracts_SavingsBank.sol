pragma solidity ^0.4.4;

contract SavingsBank {
  function SavingsBank() {
    // constructor
  }

  uint16[] balances;

  function getBalance(uint8 accountNumber) returns (uint) {
    return balances[accountNumber];    
  }

  function addAccountWithBalance(uint16 balance) {
    balances.push(balance);
  }

  function getAccountCount() returns (uint count) {
    count = balances.length;
  }
}
