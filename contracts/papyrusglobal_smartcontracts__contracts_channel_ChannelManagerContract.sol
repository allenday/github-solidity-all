pragma solidity ^0.4.18;

import '../common/ECRecovery.sol';
import '../common/StandardToken.sol';
import './ChannelApi.sol';
import './ChannelManagerApi.sol';
import './SettlementApi.sol';


contract ChannelManagerContract is ChannelManagerApi {
  using SafeMath for uint256;

  // STRUCTURES

  struct Channel {
    string module;
    bytes configuration;
    Participant[] participants;
    address disputeResolver;
    uint32 minBlockPeriod;
    uint32 partTimeout;
    uint32 resultTimeout;
    uint32 closeTimeout;

    uint64 opened;
    uint64 closeTimestamp;
    uint64 closed;

    mapping (uint64 => Block) blocks;
    mapping (uint64 => uint64) blockIds;
    uint64 blockCount;
  }

  struct Participant {
    address participant;
    address validator;
  }

  struct Block {
    BlockPart[] parts;
    BlockResult[] results;
    BlockSettlement settlement;
  }

  struct BlockPart {
    uint64 length;
    bytes32 hash;
    bytes reference;
  }

  struct BlockResult {
    bytes32 resultHash;
  }

  struct BlockSettlement {
    bytes result;
    bytes32 resultHash;
  }

  // PUBLIC FUNCTIONS

  function () public {
    revert();
  }

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
    returns (uint64 channel)
  {
    require(participants.length >= MIN_PARTICIPANTS && participants.length <= MAX_PARTICIPANTS);
    require(timeouts[1] > 0);
    require(timeouts[2] > 0);
    require(timeouts[3] > 0);
    channel = channelCount + 1;
    channels[channel].module = module;
    channels[channel].configuration = configuration;
    channels[channel].participants.length = participants.length;
    for (uint16 i = 0; i < participants.length; ++i) {
      channels[channel].participants[i].participant = participants[i];
      ChannelCreated(channel, participants[i]);
    }
    channels[channel].disputeResolver = disputeResolver;
    channels[channel].minBlockPeriod = timeouts[0];
    channels[channel].partTimeout = timeouts[1];
    channels[channel].resultTimeout = timeouts[2];
    channels[channel].closeTimeout = timeouts[3];
    channels[channel].opened = uint64(now);
    channelCount += 1;
  }

  function requestClose(uint64 channel) public onlyParticipant(channel) {
    require(channels[channel].closeTimestamp == 0); 
    channels[channel].closeTimestamp = uint64(now) + channels[channel].closeTimeout;
    ChannelCloseRequested(channel, channels[channel].closeTimestamp);
  }

  // PUBLIC FUNCTIONS (CHANNELS INTERACTION)

  function approve(uint64 channel, address validator) public notClosedChannel(channel) {
    require(validator != address(0));
    int8 participantIndex = getParticipantIndex(channel, msg.sender);
    require(participantIndex >= 0);
    uint8 i = uint8(participantIndex);
    require(channels[channel].participants[i].validator == 0);
    channels[channel].participants[i].validator = validator;
    ChannelApproved(channel, msg.sender);
  }

  function setBlockPart(uint64 channel, uint64 blockId, uint64 length, bytes32 hash, bytes reference)
    public
    notClosed(channel, blockId)
  {
    require(blockStart(blockId) + channels[channel].partTimeout >= now);
    require(reference.length > 0);
    int8 validatorIndex = getValidatorIndex(channel, msg.sender);
    require(validatorIndex >= 0);
    uint8 i = uint8(validatorIndex);
    if (channels[channel].blocks[blockId].parts.length == 0) {
      uint64 lastBlockId = lastBlock(channel);
      if (blockId > lastBlockId) {
        require(blockStart(blockId) - blockStart(lastBlockId) >= channels[channel].minBlockPeriod);
        channels[channel].blockIds[channels[channel].blockCount] = blockId;
        channels[channel].blockCount++;
      }
      channels[channel].blocks[blockId].parts.length = channels[channel].participants.length;
    }
    channels[channel].blocks[blockId].parts[i].hash = hash;
    channels[channel].blocks[blockId].parts[i].reference = reference;
    channels[channel].blocks[blockId].parts[i].length = length;
    ChannelNewBlockPart(channel, msg.sender, blockId, length, hash, reference);
  }

  function setBlockResult(uint64 channel, uint64 blockId, bytes32 resultHash)
    public
    notClosed(channel, blockId)
    canStoreBlockResult(channel, blockId, resultHash)
  {
    int8 validatorIndex = getValidatorIndex(channel, msg.sender);
    require(validatorIndex >= 0);
    uint8 i = uint8(validatorIndex);
    if (channels[channel].blocks[blockId].results.length == 0) {
      channels[channel].blocks[blockId].results.length = channels[channel].participants.length;
    }
    require(channels[channel].blocks[blockId].results[i].resultHash == 0);
    channels[channel].blocks[blockId].results[i].resultHash = resultHash;
    ChannelNewBlockResult(channel, msg.sender, blockId, resultHash);
  }

  function blockSettle(uint64 channel, uint64 blockId, bytes result)
    public
    onlyValidator(channel)
    notClosed(channel, blockId)
    canSettle(channel, blockId, result)
  {
    channels[channel].blocks[blockId].settlement.result = result;
    channels[channel].blocks[blockId].settlement.resultHash = keccak256(result);
    ChannelBlockSettled(channel, msg.sender, blockId, result);
  }

  function blockResolveDispute(uint64 channel, uint64 blockId, bytes result)
    public
    onlyValidator(channel)
    notClosed(channel, blockId)
    canResolveDispute(channel, blockId, result)
  {
    // TODO: Here can be additional logic to control such dispute resolution
    channels[channel].blocks[blockId].settlement.result = result;
    channels[channel].blocks[blockId].settlement.resultHash = keccak256(result);
    ChannelBlockSettled(channel, msg.sender, blockId, result);
  }
  
  // FUNCTIONS

  function channelModule(uint64 channel) public view returns (string) {
    return channels[channel].module;
  }

  function channelConfiguration(uint64 channel) public view returns (bytes) {
    return channels[channel].configuration;
  }

  function channelParticipantCount(uint64 channel) public view returns (uint64) {
    return uint64(channels[channel].participants.length);
  }

  function channelDisputeResolver(uint64 channel) public view returns (address) {
    return channels[channel].disputeResolver;
  }

  function channelParticipant(uint64 channel, uint64 participantId) public view returns (address) {
    return channels[channel].participants[participantId].participant;
  }

  function channelValidator(uint64 channel, uint64 participantId) public view returns (address) {
    return channels[channel].participants[participantId].validator;
  }

  function channelPartTimeout(uint64 channel) public view returns (uint32) {
    return channels[channel].partTimeout;
  }

  function channelResultTimeout(uint64 channel) public view returns (uint32) {
    return channels[channel].resultTimeout;
  }

  function channelCloseTimeout(uint64 channel) public view returns (uint32) {
    return channels[channel].closeTimeout;
  }

  function channelOpened(uint64 channel) public view returns (uint64) {
    return channels[channel].opened;
  }

  function channelCloseTimestamp(uint64 channel) public view returns (uint64) {
    return channels[channel].closeTimestamp;
  }

  function lastBlock(uint64 channel) public view returns (uint64) {
    return channels[channel].blockCount > 0 ? channels[channel].blockIds[channels[channel].blockCount - 1] : 0;
  }

  function blockCount(uint64 channel) public view returns (uint64) {
    return channels[channel].blockCount;
  }

  function blockIndex(uint64 channel, uint64 blockId) public view returns (uint64) {
    return channels[channel].blockIds[blockId];
  }

  function blockPart(uint64 channel, uint64 participantId, uint64 blockId)
    public
    view
    returns (uint64 length, bytes32 hash, bytes reference)
  {
    length = channels[channel].blocks[blockId].parts[participantId].length;
    hash = channels[channel].blocks[blockId].parts[participantId].hash;
    reference = channels[channel].blocks[blockId].parts[participantId].reference;
  }

  function blockResult(uint64 channel, uint64 participantId, uint64 blockId)
    public
    view
    returns (bytes32 resultHash)
  {
    resultHash = channels[channel].blocks[blockId].results[participantId].resultHash;
  }

  function blockSettlement(uint64 channel, uint64 blockId)
    public
    view
    returns (bytes result)
  {
    result = channels[channel].blocks[blockId].settlement.result;
  }

  function blockSettlementHash(uint64 channel, uint64 blockId)
    public
    view
    returns (bytes32 resultHash)
  {
    resultHash = channels[channel].blocks[blockId].settlement.resultHash;
  }

  function hashState(address _channel, uint256 _nonce, uint256 _receiverPayment, uint256 _auditorPayment) public pure returns (bytes32) {
    return keccak256(_channel, _nonce, _receiverPayment, _auditorPayment);
  }

  function hashTransfer(address _transferId, address _channel, bytes _lockData, uint256 _sum) public pure returns (bytes32) {
    if (_lockData.length > 0) {
      return keccak256(_transferId, _channel, _sum, _lockData);
    } else {
      return keccak256(_transferId, _channel, _sum);
    }
  }

  // PRIVATE FUNCTIONS

  // returns block start timestamp  
  function blockStart(uint64 blockId) private pure returns (uint64) {
    return blockId;
  }

  function getParticipantIndex(uint64 channel, address participantAddress) private view returns (int8) {
    for (uint8 i = 0; i < channels[channel].participants.length; ++i) {
      if (channels[channel].participants[i].participant == participantAddress) {
        return int8(i);
      }
    }
    return -1;
  }

  function isParticipant(uint64 channel, address participantAddress) private view returns (bool) {
    return getParticipantIndex(channel, participantAddress) >= 0;
  }

  function getValidatorIndex(uint64 channel, address validator) private view returns (int8) {
    for (uint8 i = 0; i < channels[channel].participants.length; ++i) {
      if (channels[channel].participants[i].validator == validator) {
        return int8(i);
      }
    }
    return -1;
  }

  function isValidator(uint64 channel, address validator) private view returns (bool) {
    return getValidatorIndex(channel, validator) >= 0;
  }

  // MODIFIERS

  modifier onlyParticipant(uint64 channel) {
    require(isParticipant(channel, msg.sender));
    _;
  }

  modifier onlyValidator(uint64 channel) {
    require(isValidator(channel, msg.sender));
    _;
  }

  modifier notClosedChannel(uint64 channel) {
    require(channels[channel].closeTimestamp == 0 || channels[channel].closeTimestamp > now);
    _;
  }

  modifier notClosed(uint64 channel, uint64 blockId) {
    require(channels[channel].closeTimestamp == 0 || channels[channel].closeTimestamp > blockStart(blockId));
    _;
  }

  modifier canStoreBlockResult(uint64 channel, uint64 blockId, bytes32 resultHash) {
    if (blockStart(blockId) + channels[channel].partTimeout >= now) {
      for (uint8 i = 0; i < channels[channel].participants.length; ++i) {
        require(channels[channel].participants[i].validator == address(0) ||
          channels[channel].blocks[blockId].parts[i].hash != 0);
      }
    }
    require(blockStart(blockId) + channels[channel].resultTimeout >= now);
    _;
  }

  modifier canSettle(uint64 channel, uint64 blockId, bytes result) {
    require(channels[channel].blocks[blockId].settlement.result.length == 0);
    require(result.length > 0);
    uint8 i;
    var resultHash = keccak256(result);
    if (blockStart(blockId) + channels[channel].resultTimeout >= now) {
      // Require results from all approved participants are stored
      for (i = 0; i < channels[channel].participants.length; ++i) {
        require(channels[channel].participants[i].validator == address(0) ||
          channels[channel].blocks[blockId].results[i].resultHash == resultHash);
      }
    } else {
      // Check only stored results since allowed time to store them is over
      for (i = 0; i < channels[channel].participants.length; ++i) {
        require(channels[channel].blocks[blockId].results[i].resultHash == 0 ||
          channels[channel].blocks[blockId].results[i].resultHash == resultHash);
      }
    }
    _;
  }

  modifier canResolveDispute(uint64 channel, uint64 blockId, bytes result) {
    require(channels[channel].disputeResolver == msg.sender);
    require(channels[channel].blocks[blockId].settlement.result.length == 0);
    require(result.length > 0);
    var resultHash = keccak256(result);
    bool consensus = true;
    uint8 validatorCount = 0;
    for (uint8 i = 0; i < channels[channel].participants.length; ++i) {
      if (channels[channel].participants[i].validator != address(0)) {
        if (channels[channel].blocks[blockId].results[i].resultHash != resultHash) {
          consensus = false;
        }
        ++validatorCount;
      }
    }
    require(!consensus && validatorCount > 1);
    _;
  }

  // FIELDS

  mapping (uint64 => Channel) public channels;
  uint64 public channelCount;

  uint8 constant MIN_PARTICIPANTS = 2;
  uint8 constant MAX_PARTICIPANTS = 16;
}
