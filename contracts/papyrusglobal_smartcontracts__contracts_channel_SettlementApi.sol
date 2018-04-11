pragma solidity ^0.4.18;


contract SettlementApi {

  // EVENTS

  event Deposit(address indexed sender, uint256 balance);
  event Withdraw(address indexed receiver, uint256 balance);

  event ChannelCreated(uint64 channel, uint64 channelInternal, string module, bytes configuration,
    address partner, address partnerPaymentAddress, address[] auditors, uint256[] auditorsRates, address disputeResolver, uint32[] timeouts);
  event Settle(address indexed sender, uint64 channel, uint64 blockId, uint64[] impressions, uint256[] sums,
    address[] paymentReceivers, uint256[] paymentAmounts);

  // PUBLIC FUNCTIONS
  
  function deposit(uint256 amount) public returns (bool success, uint256 balance);
  function withdraw(uint256 amount) public returns (bool success, uint256 balance);

  function createChannel(string module, bytes configuration, address partner, address partnerPaymentAddress, address[] auditors,
    uint256[] auditorsRates, address disputeResolver, uint32[] timeouts) public returns (uint64 channel);
  function settle(address partner, uint64 channel, uint64 blockId, bytes result) public;

  // INTERNAL FUNCTIONS

  function feeReceiver() internal view returns (address);
}
