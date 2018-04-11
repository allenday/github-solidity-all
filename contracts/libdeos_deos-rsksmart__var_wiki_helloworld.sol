pragma solidity ^0.4.4;

contract HolaMundo{
  uint public balance;
  
  function HolaMundo(){
    balance = 1000;
  }
  
  function getBalance() returns (uint){
    return balance;
  }

}