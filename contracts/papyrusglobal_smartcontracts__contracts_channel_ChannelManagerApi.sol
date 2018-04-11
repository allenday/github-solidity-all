pragma solidity ^0.4.18;

import '../common/StandardToken.sol';
import './ChannelApi.sol';
import './SettlementApi.sol';


contract ChannelManagerApi {

  // EVENTS

  event ChannelCreated(uint64 indexed channel, address indexed participant);
  event ChannelApproved(uint64 indexed channel, address indexed participant);
  event ChannelCloseRequested(uint64 indexed channel, uint64 timestamp);
  event ChannelNewBlockPart(uint64 indexed channel, address indexed participant, uint64 blockId, uint64 length, bytes32 hash, bytes reference);
  event ChannelNewBlockResult(uint64 indexed channel, address indexed participant, uint64 blockId, bytes32 resultHash);
  event ChannelBlockSettled(uint64 indexed channel, address indexed participant, uint64 blockId, bytes result);

  // PUBLIC FUNCTIONS (CHANNELS MANAGEMENT)

  function createChannel(
    // validator module name
    string module,
    // module-specific configuration 
    bytes configuration,
    // addresses of participants 
    address[] participants,
    // address from which block can be settled with any data in case of dispute 
    address disputeResolver,
    // timeouts in seconds:
    // timeouts[0] - minimal period in seconds between two subsequent blocks
    // timeouts[1] - timeout between now and blockStart checked in setPartResult
    // timeouts[2] - timeout between now and blockStart checked in setBlockResult
    // timeouts[3] - timeout between and now and closeTimestamp set in requestClose
    uint32[] timeouts
  )
  public
  returns (uint64 channel);
  
  // Closing channel
  function requestClose(uint64 channel) public;

  // Writting data to channel
  function approve(uint64 channel, address validator) public;
  function setBlockPart(uint64 channel, uint64 blockId, uint64 length, bytes32 hash, bytes reference) public;
  function setBlockResult(uint64 channel, uint64 blockId, bytes32 resultHash) public;
  function blockSettle(uint64 channel, uint64 blockId, bytes result) public;
  function blockResolveDispute(uint64 channel, uint64 blockId, bytes result) public;

  // Read channel information
  function channelModule(uint64 channel) public view returns (string);
  function channelConfiguration(uint64 channel) public view returns (bytes);
  function channelParticipantCount(uint64 channel) public view returns (uint64);
  function channelParticipant(uint64 channel, uint64 participantId) public view returns (address);
  function channelValidator(uint64 channel, uint64 participantId) public view returns (address);

  // Read channel blocks information
  function blockPart(uint64 channel, uint64 participantId, uint64 blockId) public view returns (uint64 length, bytes32 hash, bytes reference);
  function blockResult(uint64 channel, uint64 participantId, uint64 blockId) public view returns (bytes32 resultHash);
  function blockSettlement(uint64 channel, uint64 blockId) public view returns (bytes result);
  function blockSettlementHash(uint64 channel, uint64 blockId) public view returns (bytes32 resultHash);
}
