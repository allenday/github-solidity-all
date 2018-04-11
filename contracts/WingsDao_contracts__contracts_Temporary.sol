pragma solidity ^0.4.8;

contract Temporary {
  uint public startTimestamp;
  uint public endTimestamp;
  address public timeManager;

  modifier inTime {
    if (startTimestamp > block.timestamp || endTimestamp < block.timestamp) {
      throw;
    }

    _;
  }

  modifier before {
    if (startTimestamp != 0 || endTimestamp != 0) {
      throw;
    }

    _;
  }

  modifier onlyTimeManager {
    if (msg.sender != timeManager) {
      throw;
    }

    _;
  }

  function setTime(uint _start, uint _end) public onlyTimeManager() before() {
    if (_start >= _end) {
      throw;
    }

    startTimestamp = _start;
    endTimestamp = _end;
  }
}
