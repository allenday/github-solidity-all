pragma solidity ^0.4.18;

import './CampaignContract.sol';


contract CampaignManagerContract {

  // EVENTS

  event CampaignCreated(uint64 campaignIndex, address campaignAddress);

  // PUBLIC FUNCTIONS

  function CampaignManagerContract(address _token, address _channelManager) public {
    require(_token != address(0) && _channelManager != address(0));
    token = StandardToken(_token);
    channelManager = ChannelManagerContract(_channelManager);
  }

  function () public {
    revert();
  }

  function createCampaign(
    address _dsp,
    uint256 _feeRate,
    string _dbId
  )
    public
    returns (address campaign)
  {
    campaign = new CampaignContract(token, channelManager, msg.sender, _dsp, _feeRate, _dbId);
    campaigns[campaignCount] = campaign;
    campaignCount += 1;
    CampaignCreated(campaignCount - 1, campaign);
  }

  function createCampaignAndChannels(
    address _dsp,
    uint256 _feeRate,
    string _dbId,
    address[] ssps,
    address[] sspContracts,
    address[] auditors,
    uint256[] auditorsRates,
    address disputeResolver,
    string module,
    bytes configuration,
    uint32[] timeouts
  )
    public
    returns (CampaignContract campaign)
  {
    require(ssps.length > 0);
    campaign = new CampaignContract(token, channelManager, msg.sender, _dsp, _feeRate, _dbId);
    for (uint32 i = 0; i < ssps.length; ++i) {
      campaign.createChannel(module, configuration, ssps[i], sspContracts[i], auditors, auditorsRates, disputeResolver, timeouts);
    }
    campaigns[campaignCount] = campaign;
    campaignCount += 1;
    CampaignCreated(campaignCount - 1, campaign);
  }

  // FIELDS

  StandardToken public token;
  ChannelManagerContract public channelManager;

  mapping (uint64 => address) public campaigns;
  uint64 public campaignCount;
}
