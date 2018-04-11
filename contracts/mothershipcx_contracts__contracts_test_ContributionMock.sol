pragma solidity ^0.4.11;

import '../Contribution.sol';

// @dev ContributionMock mocks current block number

contract ContributionMock is Contribution {

  function ContributionMock() Contribution() {}

  function getBlockNumber() internal constant returns (uint) {
    return mock_blockNumber;
  }

  function setMockedBlockNumber(uint _b) public {
    mock_blockNumber = _b;
  }

  uint mock_blockNumber = 1;
}
