pragma solidity ^0.4.11;

import '../SIT.sol';

// @dev SITMock mocks current block number

contract SITMock is SIT {

  function SITMock(address _tokenFactory) SIT(_tokenFactory) {}

  function getBlockNumber() internal constant returns (uint) {
    return mock_blockNumber;
  }

  function setMockedBlockNumber(uint _b) public {
    mock_blockNumber = _b;
  }

  uint mock_blockNumber = 1;
}
