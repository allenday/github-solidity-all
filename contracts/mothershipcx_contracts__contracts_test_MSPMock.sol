pragma solidity ^0.4.11;

import '../MSP.sol';

// @dev MSPMock mocks current block number

contract MSPMock is MSP {

  function MSPMock(address _tokenFactory) MSP(_tokenFactory) {}

  function getBlockNumber() internal constant returns (uint) {
    return mock_blockNumber;
  }

  function setMockedBlockNumber(uint _b) public {
    mock_blockNumber = _b;
  }

  uint mock_blockNumber = 1;
}
