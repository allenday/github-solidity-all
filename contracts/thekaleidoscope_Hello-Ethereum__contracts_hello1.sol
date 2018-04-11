pragma solidity ^0.4.4;

contract hello1 {
  uint public balance;
  function hello1() {
    balance=1000;
  }

  function getBalance() constant returns(uint){
    return(balance);

  }
  function deposit(uint val) returns (uint newval){
    balance+=val;
    return(balance);


  }
}
