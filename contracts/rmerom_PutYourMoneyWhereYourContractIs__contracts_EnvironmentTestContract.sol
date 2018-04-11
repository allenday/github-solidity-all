pragma solidity ^0.4.4;

import "./EnvironmentContractInterface.sol";

/**
 * Can be used as the Environment during testing and bounty challenges.
 * Of course, you do not have to use this contract, you can create a similar one.
 */
contract EnvironmentTestContract is EnvironmentContractInterface {
  address owner;
  
  mapping(uint =>bytes32) blockHash;
  address coinbase;
  uint currentBlockNumber;
  uint difficulty;
  uint gasLimit;
  uint timestamp;
  
  modifier lockedToOwner {
    if (owner != 0 && msg.sender != owner) throw;
    _;
  }
  
  function getOwner() returns (address) {
    return owner;
  }
  
  /**
    Alows setting and locking the owner of this environment contract, to
    disable malicious actors from calling its setXXX functions.
    Note we set the owner manually, as the creator of this contract is the
    BountyContract, not the challenger.
  */ 
  function lockOwner(address _owner) {
      //if (owner != 0) throw;
      owner = _owner; 
  }
  
  /**
   * Returns the block hash set for this block by setBlockDotBlockHash(),
   * or, if none has been set, the prod block hash.
   */
  function blockDotBlockHash(uint forBlockNumber) returns (bytes32) {
      if (int(forBlockNumber) < (int(currentBlockNumber - 256)) 
          || (forBlockNumber >= currentBlockNumber)) {
          // Spec allows acceessing [currentblock-256, currentblock) only,
          // otherwise returns 0.
          return 0;
      }
      bytes32 hash = blockHash[forBlockNumber];
      if (hash == 0) {
          // Not explicitly set, return prod value.
          return block.blockhash(forBlockNumber);
      }
      return hash;
  }
  
  function blockDotCoinbase() returns (address) {
      return (coinbase != 0) ? coinbase : block.coinbase;
  }
  
  function blockDotDifficulty() returns (uint) {
      return (difficulty != 0) ? difficulty : block.difficulty;
  }
  
  function blockDotGasLimit() returns (uint) {
      return (gasLimit != 0) ? gasLimit : block.gaslimit;
  }
  
  function blockDotNumber() returns (uint) {
      return (currentBlockNumber != 0) ? currentBlockNumber : block.number;
  }
  
  function blockDotTimestamp() returns (uint) {
      return (timestamp != 0) ? timestamp : block.timestamp;
  }
  
  function now() returns (uint) {
      return (timestamp != 0) ? timestamp : block.timestamp;
  }

  function setBlockDotBlockHash(uint forBlockNumber, bytes32 _blockHash) lockedToOwner {
      // May never change once set.
      if (blockHash[forBlockNumber] != 0) throw;
      blockHash[forBlockNumber] = _blockHash;
  }
  
  function setBlockDotCoinbase(address addr) lockedToOwner {
      if (addr == 0) throw;
      coinbase = addr;
  }
  
  function setBlockDotDifficulty(uint _difficulty) lockedToOwner {
      if (_difficulty == 0) throw;
      difficulty = _difficulty;
  }
  
  function setBlockDotGasLimit(uint _gasLimit) lockedToOwner {
    // Gas can only set once per block.
    if (gasLimit > 0) throw;
    gasLimit = _gasLimit;
  }
  
  function setBlockDotNumber(uint blockNumber) lockedToOwner {
      // Time can only move forward.
      if (blockNumber <= currentBlockNumber) throw;
      currentBlockNumber = blockNumber;
      // Let user re-set gas limit.
      gasLimit = 0;
  }
  function setBlockDotTimestamp(uint _timestamp) lockedToOwner {
      // Time can only move forward.
      if (_timestamp < timestamp) throw;
      timestamp = _timestamp;
  }
}
