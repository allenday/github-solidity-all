pragma solidity ^0.4.18;

import '../common/StandardToken.sol';
import '../common/SafeOwnable.sol';
import './ChannelManagerContract.sol';
import './SettlementApi.sol';


contract RtbSettlementContract is SafeOwnable, SettlementApi {
  using SafeMath for uint256;

  // PUBLIC FUNCTIONS

  function RtbSettlementContract(address _token, address _channelManager, address _payer, uint256 _feeRate) public {
    require(_token != address(0) && _channelManager != address(0) && _payer != address(0));
    token = StandardToken(_token);
    channelManager = ChannelManagerContract(_channelManager);
    payer = _payer;
    feeRate = _feeRate;
  }

  /// @notice Sender deposits amount of tokens.
  /// @param amount The amount to be deposited to the contract
  /// @return success Success if the transfer was successful
  /// @return contractBalance The new contractBalance of the contract
  function deposit(uint256 amount) public returns (bool success, uint256 contractBalance) {
    require(token.balanceOf(msg.sender) >= amount);
    success = token.transferFrom(msg.sender, this, amount);
    if (success) {
      Deposit(msg.sender, token.balanceOf(this));
    }
    return (success, token.balanceOf(this));
  }

  /// @notice Sender withdraws amount of tokens.
  /// @param amount The amount to be withdrawn from the contract
  /// @return success Success if the transfer was successful
  /// @return contractBalance The new contractBalance of the contract
  function withdraw(uint256 amount) public onlyOwner returns (bool success, uint256 contractBalance) {
    require(token.balanceOf(this) >= amount);
    success = token.transfer(owner, amount);
    if (success) {
      Withdraw(owner, token.balanceOf(this));
    }
    return (success, token.balanceOf(this));
  }

  function createChannel(
    string module,
    bytes configuration,
    address partner,
    address partnerPaymentAddress,
    address[] auditors,
    uint256[] _auditorsRates,
    address disputeResolver,
    uint32[] timeouts
  )
    public
    returns (uint64 channel)
  {
    require(auditors.length == _auditorsRates.length);
    address[] memory participants = new address[](2 + auditors.length);
    participants[0] = payer;
    participants[1] = partner;
    for (uint8 i = 0; i < auditors.length; ++i) {
      participants[2 + i] = auditors[i];
      auditorsRates[partner][auditors[i]] = _auditorsRates[i];
    }
    channel = channelManager.createChannel(module, configuration, participants, disputeResolver, timeouts);
    if (channelCounts[partner] == 0) {
      partners[partnerCount] = partner;
      partnerCount += 1;
    }
    channelIndexes[partner][channelCounts[partner]] = channel;
    channelPaymentReceivers[partner][channelCounts[partner]] = partnerPaymentAddress;
    channelCounts[partner] += 1;
    ChannelCreated(channelCounts[partner] - 1, channel, module, configuration, partner,
      partnerPaymentAddress, auditors, _auditorsRates, disputeResolver, timeouts);
  }

  function settle(address partner, uint64 channel, uint64 blockId, bytes result) public {
    require(!channelSettlements[partner][channel][blockId]);
    require(result.length > 0);
    uint64 channelInternal = channelIndexes[partner][channel];
    require(channelInternal > 0);
    uint64 participantCount = channelManager.channelParticipantCount(channelInternal);
    require(participantCount > 0);
    require(keccak256(result) == channelManager.blockSettlementHash(channelInternal, blockId));
    channelSettlements[partner][channel][blockId] = true;
    uint64[] memory impressions = parseImpressions(participantCount - 2, result);
    uint256[] memory sums = parseSums(result);
    require(sums[1] >= sums[2]);
    uint256 partnerPayment = sums[1].sub(sums[2]);
    // 0 - fee payment
    // 1 - partner payment
    // 2+ - auditors payments
    address[] memory receivers = new address[](participantCount);
    receivers[0] = feeReceiver();
    receivers[1] = channelPaymentReceivers[partner][channel];
    uint256[] memory amounts = new uint256[](participantCount);
    amounts[0] = partnerPayment.mul(feeRate).div(10**18);
    amounts[1] = partnerPayment.sub(amounts[0]);
    for (uint8 i = 2; i < participantCount; ++i) {
      receivers[i] = channelManager.channelParticipant(channelInternal, i);
      amounts[i] = auditorsRates[partner][receivers[i]].mul(impressions[i + 2]);
    }
    performTransfers(receivers, amounts);
    Settle(msg.sender, channel, blockId, impressions, sums, receivers, amounts);
  }

  // PRIVATE FUNCTIONS

  function parseImpressions(uint64 auditorCount, bytes result) private pure returns(uint64[] impressions) {
    uint64 totalImpressions;
    uint64 viewedImpressions;
    uint64 rejectedImpressions;
    uint64 clickImpressions;
    assembly {
      totalImpressions := mload(add(result, 0x20))
      viewedImpressions := mload(add(result, 0x60))
      rejectedImpressions := mload(add(result, 0xA0))
      clickImpressions := mload(add(result, 0xE0))
    }
    // 0 - totalImpressions
    // 1 - viewedImpressions
    // 2 - rejectedImpressions
    // 3 - clickImpressions
    // 4+ - precessedImpressions by each auditor
    impressions = new uint64[](4 + auditorCount);
    impressions[0] = totalImpressions;
    impressions[1] = viewedImpressions;
    impressions[2] = rejectedImpressions;
    impressions[3] = clickImpressions;
    for (uint8 i = 0; i < auditorCount; ++i) {
      uint64 precessedImpressions;
      assembly {
        precessedImpressions := mload(add(add(result, 0x120), mul(i, 0x20)))
      }
      impressions[4 + i] = precessedImpressions;
    }
  }

  function parseSums(bytes result) private pure returns(uint256[] sums) {
    uint256 totalSum;
    uint256 viewedSum;
    uint256 rejectedSum;
    uint256 clickSum;
    assembly {
      totalSum := mload(add(result, 0x40))
      viewedSum := mload(add(result, 0x80))
      rejectedSum := mload(add(result, 0xC0))
      clickSum := mload(add(result, 0x100))
    }
    // 0 - totalSum
    // 1 - viewedSum
    // 2 - rejectedSum
    // 3 - clickSum
    sums = new uint256[](4);
    sums[0] = totalSum;
    sums[1] = viewedSum;
    sums[2] = rejectedSum;
    sums[3] = clickSum;
  }

  function performTransfers(address[] receivers, uint256[] amounts) private {
    require(receivers.length >= 2 && receivers.length == amounts.length);
    for (uint8 i = 0; i < receivers.length; ++i) {
      if (receivers[i] != address(0) && amounts[i] > 0) {
        require(token.transfer(receivers[i], amounts[i]));
      }
    }
  }

  // FIELDS

  StandardToken public token;
  ChannelManagerContract public channelManager;
  address public payer;
  uint256 public feeRate;

  mapping (uint64 => address) public partners;
  uint64 public partnerCount;

  mapping (address => mapping (address => uint256)) public auditorsRates;

  mapping (address => mapping (uint64 => uint64)) public channelIndexes;
  mapping (address => mapping (uint64 => address)) public channelPaymentReceivers;
  mapping (address => uint64) public channelCounts;

  mapping (address => mapping (uint64 => mapping (uint64 => bool))) public channelSettlements;
}
