pragma solidity ^0.4.8;

contract priced {
  // Modifiers can receive arguments:
  modifier costs(uint price) {
    if (msg.value >= price) {
      _;
    }
  }
}

