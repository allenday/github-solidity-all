pragma solidity ^0.4.8;

contract TestContract2 {
  uint public aa;
  function TestContract(){

  }

  function setAA(uint b) {
    aa = b;
  }
}
contract TestContract {
  TestContract2 test2;

  function TestContract(){

  }

  function setIt(address addr){
    test2 = TestContract2(addr);
  }

  function callIt(uint b) {
    test2.setAA(4);
  }
}
