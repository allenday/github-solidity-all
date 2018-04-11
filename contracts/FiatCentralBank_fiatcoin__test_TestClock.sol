pragma solidity ^0.4.13;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/time/Clock.sol";
import "../contracts/time/NowClock.sol";
import "../contracts/time/DebugClock.sol";

contract TestLibSort {
  Clock clock;

  function testNowClock() {
    clock = new NowClock();
    Assert.equal(clock.get_time(), now, "NowClock should work");
  }

  function testDebugClock() {
    uint base_time = now;
    clock = new DebugClock(base_time);
    Assert.equal(clock.get_time(), base_time, "DebugClock should work");
    DebugClock debug_clock = DebugClock(clock);
    debug_clock.set_time(base_time + 2 hours);
    Assert.equal(clock.get_time(), base_time + 2 hours, "DebugClock should warp time");
    debug_clock.set_time(base_time);
    Assert.equal(clock.get_time(), base_time, "DebugClock should warp time back");
  }
}