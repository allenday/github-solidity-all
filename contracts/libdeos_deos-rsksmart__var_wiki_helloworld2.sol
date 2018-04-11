pragma solidity ^0.4.4;

contract HelloWorld{
  uint public balance;
  
  function HelloWorld(){
    balance = 1000;
  }
  
  function getBalance() returns (uint){
    return balance;
  }

  function deposit(uint amount) returns(bool sufficient){
    
    balance+=amount;
    return true;
  }
  
}