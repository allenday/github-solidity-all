pragma solidity ^0.4.13;

import './Clock.sol';

contract DebugClock is Clock {
  uint date;

  function DebugClock(uint _date)
    public 
  {
    date = _date;
  }

  function set_time(uint _date)
    public 
  {
    date = _date;
  }

  function get_time()
    public
    returns (uint)
  {
    return date;
  }
}
