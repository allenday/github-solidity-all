pragma solidity ^0.4.4;

contract hello2{
  address public owner;
  mapping (address=>uint) balance;


  function hello2(){
    owner=msg.sender;
    balance[owner]=1000;
  }

  function getBalance(address usr) constant returns (uint bal){
    return balance[usr];

  }

  function transfer(address to,uint val) returns (bool Success){
    if(balance[owner]<val){
      return false;
    }
    balance[owner]-=val;
    balance[to]+=val;
    return true;
  }



}
