pragma solidity ^0.4.18;

library SafeMath {

  // a * b
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  // a div b
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    return c;
  }

  // a - b 
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  // a + b
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}
