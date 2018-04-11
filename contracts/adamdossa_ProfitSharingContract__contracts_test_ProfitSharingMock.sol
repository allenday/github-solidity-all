pragma solidity ^0.4.11;

import '../ProfitSharing.sol';

contract ProfitSharingMock is ProfitSharing {

  event MockNow(uint _now);

  uint mock_now = 1;

  function ProfitSharingMock(address _miniMeToken)
  ProfitSharing(_miniMeToken)
  {}

  function getNow() internal constant returns (uint) {
      return mock_now;
  }

  function setMockedNow(uint _b) public {
      mock_now = _b;
      MockNow(_b);
  }

}
