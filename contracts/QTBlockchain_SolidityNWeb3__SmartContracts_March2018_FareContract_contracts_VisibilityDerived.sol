pragma solidity ^0.4.4;

import "./VisibilityDemo.sol";

contract VisibilityDerived is VisibilityDemo {
  function VisibilityDerived() {
    // constructor
  }

  function test() {
    IsThisInternal();
  }
}
