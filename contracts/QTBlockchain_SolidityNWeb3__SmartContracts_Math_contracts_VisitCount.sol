pragma solidity ^0.4.4;
import './MathUtil.sol';

contract VisitCount {
  function VisitCount() {
    // constructor
  }

  uint count = 0;

  function visit() {
    count++;
  } 

  function getVisitorCount() returns (uint) {
    return count;
  }

  function addFakeVisitors() {
    var mathUtil = new MathUtil();
    count = mathUtil.square(count);
  }
}
