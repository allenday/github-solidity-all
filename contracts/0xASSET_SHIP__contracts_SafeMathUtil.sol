pragma solidity ^0.4.15;

import "./SafeMath.sol";


library SafeMathUtil {
  using SafeMath for uint256;

  /**
   * Calculates percentage y of x, where y is represented in basis points e.g. 100 = 1%
   */
  function basis(uint256 x, uint256 y) internal constant returns (uint256) {
    return x.mul(y).div(10000);
  }

  /**
   * As value moves between lowerBound and upperBound, returns a value that moves proportionally between start and end
   */
  function scale(uint256 value, uint256 lowerBound, uint256 upperBound, uint256 start, uint256 end) internal constant returns (uint256) {
    assert(lowerBound < upperBound);
    if (value <= lowerBound) 
      return start;
    if (value >= upperBound) 
      return end;

    return mid(upperBound.sub(lowerBound).div(value.sub(lowerBound)), start, end);
  }

  /**
   * Returns a value that is 1/ratio between start and end
   */
  function mid(uint256 ratio, uint256 start, uint256 end) internal constant returns (uint256) {
    if (start < end) 
      return start.add(end.sub(start).div(ratio));

    return start.sub(start.sub(end).div(ratio));
  }
}
