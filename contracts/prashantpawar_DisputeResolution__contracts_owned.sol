pragma solidity ^0.4.2;

contract owned {
  address owner;

  modifier onlyowner() {
    if (msg.sender == owner) {
      _;
    }
  }

  function owned() {
    owner = msg.sender;
  }
}
