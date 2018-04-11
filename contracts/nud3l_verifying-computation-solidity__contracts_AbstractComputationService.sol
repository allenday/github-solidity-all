pragma solidity ^0.4.8;

contract AbstractComputationService {
  function __callback(bytes32 _oraclizeID, string _result);

  function compute(string _val1, string _val2, uint _operation, uint256 _computationId) payable;

  function provideIndex(string _resultSolver, uint _computationId);

  function registerOperation(uint _operation, string _query);

  function enableArbiter(address _arbiterAddress);

  function disableArbiter(address _arbiterAddress);

  function getResult(bytes32 _oraclizeID) constant returns (string);

  function stringToUint(string s) internal constant returns (uint result);

  function uintToBytes(uint v) constant internal returns (bytes32 ret);

  function bytes32ToString(bytes32 x) constant returns (string);
}
