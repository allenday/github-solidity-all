/**
   A simplistic PiggyBank that stores a value in a mapping of address to number.
   This builds on the Counter.sol example showing usage of mapping type,
    accounts,msg.sender.
     . Stores just a number.Not real crypto like BTC,Ether or any Alt coins.

*/

pragma solidity ^0.4.2;

/** @title PiggyBank */
contract PiggyBank {

  mapping (address => uint) balances;

  /* A new account */
  function PiggyBank(){
      //can msg.sender be null?
      balances[msg.sender] = 0; //All new accounts start with zero
  }

  function deposit(uint amount) external {
      balances[msg.sender] += amount;
  }

  function withdraw(uint amount) external returns (bool success){
    //check conditions
      if(amount > balances[msg.sender]){return false; }
      balances[msg.sender]-=amount;
      return true;
  }

  function checkBalance(address owner) returns (uint balance) {
    return balances[owner];
  }

  function checkBalance() returns (uint balance) {
    return this.checkBalance(msg.sender);
  }

}
