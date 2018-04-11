pragma solidity ^0.4.4;

import "./strings.sol";

contract StringDemo {
  function StringDemo() {
    // constructor
  }

  string content = "Hello";

  function getElementAt(uint256 index) returns (byte) {
    bytes eqBytes = bytes(content);
    return eqBytes[index];
  }

  function getSize() returns (uint256) {
    bytes eqBytes = bytes(content);
    return eqBytes.length;
  }
}
