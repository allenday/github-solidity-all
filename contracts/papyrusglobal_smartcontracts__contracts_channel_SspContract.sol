pragma solidity ^0.4.18;

import '../common/StandardToken.sol';
import './RtbSettlementContract.sol';


contract SspContract is RtbSettlementContract {

  // PUBLIC FUNCTIONS

  function SspContract(
    address _token,
    address _channelManager,
    address _ssp,
    uint256 _feeRate,
    string _dbId
  )
    RtbSettlementContract(_token, _channelManager, _ssp, _feeRate)
    public
  {
    dbId = _dbId;
    owner = _ssp;
  }

  function () public {
    revert();
  }

  function deposit(uint256) public returns (bool, uint256) {
    // Turned off for SSP contract for now
    revert();
  }

  function withdraw(uint256) public returns (bool, uint256) {
    // Turned off for SSP contract for now
    revert();
  }

  function addPublisher(
    string module,
    bytes configuration,
    address publisher,
    address[] auditors,
    uint256[] auditorsRates,
    address disputeResolver,
    uint32[] timeouts
  )
    public
  {
    createChannel(module, configuration, publisher, publisher, auditors, auditorsRates, disputeResolver, timeouts);
  }

  function ssp() public view returns (address) {
    return payer;
  }

  function publishers(uint64 index) public view returns (address) {
    return partners[index];
  }

  function publisherCount() public view returns (uint64) {
    return partnerCount;
  }

  // INTERNAL FUNCTIONS

  function feeReceiver() internal view returns (address) {
    return payer;
  }

  // FIELDS

  string public dbId;
}
