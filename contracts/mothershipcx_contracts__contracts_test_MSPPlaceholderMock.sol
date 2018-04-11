pragma solidity ^0.4.11;

import '../MSPPlaceholder.sol';

// @dev MSPPlaceHolderMock mocks current block number

contract MSPPlaceholderMock is MSPPlaceHolder {

  uint mock_time;

  function MSPPlaceholderMock(address _controller, address _msp, address _contribution, address _sitExchanger)
    MSPPlaceHolder(_controller, _msp, _contribution, _sitExchanger) {
    mock_time = now;
  }

  function getTime() internal returns (uint) {
    return mock_time;
  }

  function setMockedTime(uint _t) public {
    mock_time = _t;
  }
}
