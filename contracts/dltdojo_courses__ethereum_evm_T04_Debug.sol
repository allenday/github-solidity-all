pragma solidity ^0.4.15;
// https://ethereum.github.io/browser-solidity/
contract Foo {
  function mul2Require(uint amount) constant returns (uint) {
    require(amount < 100);
    return amount*2;
  }
}