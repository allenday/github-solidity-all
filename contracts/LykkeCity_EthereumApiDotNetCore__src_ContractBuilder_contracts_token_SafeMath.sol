pragma solidity ^0.4.9;

contract SafeMath {
  uint256 constant public MAX_UINT256 =
    0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

  function safeAdd (uint256 x, uint256 y)
  constant internal
  returns (uint256 z) {
    if (x > MAX_UINT256 - y) throw;
    return x + y;
  }

  function safeSub (uint256 x, uint256 y)
  constant internal
  returns (uint256 z) {
    if (x < y) throw;
    return x - y;
  }

  function safeMul (uint256 x, uint256 y)
  constant internal
  returns (uint256 z) {
    if (y == 0) return 0;
    if (x > MAX_UINT256 / y) throw;
    return x * y;
  }
}
