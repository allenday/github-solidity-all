pragma solidity ^0.4.11;

import "./Token.sol";
import "./Owned.sol";

contract Locked {
  uint public period;

  function Locked(uint _period) public {
    period = _period;
  }
}