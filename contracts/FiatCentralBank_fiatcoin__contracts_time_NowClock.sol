pragma solidity ^0.4.13;

import './Clock.sol';

contract NowClock is Clock {
  function get_time()
    public
    returns (uint)
  {
    return now;
  }
}