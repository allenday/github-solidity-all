pragma solidity ^0.4.4;

contract UpdateSavingsBank {
  function UpdateSavingsBank() {
    // constructor
  }
  string[] names;
  uint16[] balances;

  function createAccountWithBalance(string name, uint16 balance) returns (uint256 accountNumber) {
    names.push(name);
    balances.push(balance);
    accountNumber = names.length-1;
  }

  function DepositAmount(uint256 accountNumber, uint16 amount) {
    balances[accountNumber] += amount;
  }

  function withdrawAmount(uint256 accountNumber, uint16 amount) {
    balances[accountNumber] -= amount;
  }

  function getAccountDetails(uint256 accountNumber) returns (string name,uint16 balance) {
    name = names[accountNumber];
    balance = balances[accountNumber];
  }
}
