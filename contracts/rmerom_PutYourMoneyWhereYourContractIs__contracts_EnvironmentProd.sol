pragma solidity ^0.4.4;

import "./EnvironmentContractInterface.sol";

/**
 * Environment contract to be used in production.
 * Alternatively, in order to save gas, you may carefully replace calls
 * to the EnvironmentInterface with the actual variable names (e.g. block.number
 * instead of env.blockDotNumber() ).
 */
contract EnvironmentProd is EnvironmentContractInterface {
  function blockDotBlockHash(uint forBlockNumber) returns (bytes32) {
      return block.blockhash(forBlockNumber);
  }
  function blockDotCoinbase() returns (address) {
      return block.coinbase;
  }
  function blockDotDifficulty() returns (uint) {
      return block.difficulty;
  }
  function blockDotGasLimit() returns (uint) {
      return block.gaslimit;
  }
  function blockDotNumber() returns (uint) {
      return block.number;
  }
  function blockDotTimestamp() returns (uint) {
      return block.timestamp;
  }
  function now() returns (uint) {
      return block.timestamp;
  }
}
