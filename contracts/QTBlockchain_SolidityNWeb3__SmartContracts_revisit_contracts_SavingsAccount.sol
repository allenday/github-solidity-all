pragma solidity ^0.4.4;

contract SavingsAccount {
  function SavingsAccount() {
    // constructor
  }

  int balance;

  function getBalance() returns (int) {
    return balance;
  }

  function deposit(int amount) {
    balance += amount;
  }

  function withdraw(int amount) {
    assert(amount<balance);
    balance -= amount;
    /*if (amount > balance) {
      revert();
      
    } else {
      
    }*/
  }
}
