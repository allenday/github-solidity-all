pragma solidity ^0.4.4;

// Part of the PutYourMoneyWhereYourContractIs (bit.do/pymwyci) project.
//
//
/**
 * @title Base contract for TargetContracts' interaction with the environment (blockchain).
 * During automated bounties, use either EnvironmentTestContract
 * or create one of your own with more, or less, constraints.
 * 
 * For production, use ProdEnvironment below, or replace references to this 
 * interface in the original TargetContract with their direct global vars*.
 * 
 * * In future, an automatic tool will do that.
 */
contract EnvironmentContractInterface {
  function blockDotBlockHash(uint forBlockNumber) returns (bytes32);
  function blockDotCoinbase() returns (address);
  function blockDotDifficulty() returns (uint);
  function blockDotGasLimit() returns (uint);
  function blockDotNumber() returns (uint);
  function blockDotTimestamp() returns (uint);
  function now() returns (uint);
}
