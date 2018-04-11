pragma solidity ^0.4.18;

import './common/SafeOwnable.sol';


contract PapyrusRegistry is SafeOwnable {

  // EVENTS

  event TokenUpdated(address contractAddress, string abi);
  event DaoUpdated(address contractAddress, string abi);
  event ChannelManagerUpdated(address contractAddress, string abi);
  event CampaignManagerUpdated(address contractAddress, string abi);
  event SspManagerUpdated(address contractAddress, string abi);
  event RtbSettlementUpdated(string abi);
  event CampaignUpdated(string abi);
  event SspUpdated(string abi);

  // PUBLIC FUNCTIONS

  function () public {
    revert();
  }

  function updateTokenContract(address contractAddress, string abi) public onlyOwner {
    tokenAddress = contractAddress;
    tokenAbi = abi;
    TokenUpdated(contractAddress, abi);
  }

  function updateDaoContract(address contractAddress, string abi) public onlyOwner {
    daoAddress = contractAddress;
    daoAbi = abi;
    DaoUpdated(contractAddress, abi);
  }

  function updateChannelManagerContract(address contractAddress, string abi) public onlyOwner {
    channelManagerAddress = contractAddress;
    channelManagerAbi = abi;
    ChannelManagerUpdated(contractAddress, abi);
  }

  function updateCampaignManagerContract(address contractAddress, string abi) public onlyOwner {
    campaignManagerAddress = contractAddress;
    campaignManagerAbi = abi;
    CampaignManagerUpdated(contractAddress, abi);
  }

  function updateSspManagerContract(address contractAddress, string abi) public onlyOwner {
    sspManagerAddress = contractAddress;
    sspManagerAbi = abi;
    SspManagerUpdated(contractAddress, abi);
  }

  function updateRtbSettlementAbi(string abi) public onlyOwner {
    rtbSettlementAbi = abi;
    RtbSettlementUpdated(abi);
  }

  function updateCampaignAbi(string abi) public onlyOwner {
    campaignAbi = abi;
    CampaignUpdated(abi);
  }

  function updateSspAbi(string abi) public onlyOwner {
    sspAbi = abi;
    SspUpdated(abi);
  }

  // FIELDS

  address public tokenAddress;
  string public tokenAbi;

  address public daoAddress;
  string public daoAbi;

  address public channelManagerAddress;
  string public channelManagerAbi;

  address public campaignManagerAddress;
  string public campaignManagerAbi;

  address public sspManagerAddress;
  string public sspManagerAbi;

  string public rtbSettlementAbi;
  string public campaignAbi;
  string public sspAbi;
}
