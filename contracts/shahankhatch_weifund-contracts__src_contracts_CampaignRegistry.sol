pragma solidity ^0.4.3;

import "Owner.sol";


contract CampaignRegistryInterface {
  /// @notice call to register the '_campaign' with the '_interface'
  /// @param _campaign the address of the campaign contract
  /// @param _interface the address of the campaign interface contract, if any
  /// @return returns the newly created campaign ID 'campaignID'
  function register(address _campaign, address _interface) public returns (uint256 campaignID);

  /// @notice call to get the campaign id 'camapignID' of campaign address '_campaign'
  /// @param _campaign the address of the campaign contract
  /// @return the campaign ID 'campaignID' as a UINT256.
  function idOf(address _campaign) constant public returns (uint256 campaignID);

  /// @notice call to get the interface address 'interface' of campaign '_campaignID'
  /// @param _campaignID the campaign ID
  /// @return the interface address of the camapign
  function abiOf(uint256 _campaignID) constant public returns (address abi);

  /// @notice call to ge the UNIX timestamp 'registered' of when a campaign was registered
  /// @param _campaignID the camapign ID
  /// @return the UNIX timestamp of when the campaign contract was registered
  function registeredAt(uint256 _campaignID) constant public returns (uint256 registered);

  /// @notice call to get the address of campaign '_campaignID'
  /// @param _campaignID the campaign ID
  /// @return the address of the campaign contract
  function addressOf(uint256 _campaignID) constant public returns (address campaign);

  /// @notice the total number of campaigns registered
  /// @return the total count 'count' of all campaigns registered as a uint256
  function numCampaigns() constant public returns (uint256 count);
}

contract CampaignRegistry is CampaignRegistryInterface {
  modifier validRegistration(address _campaign) {
    // campaign owner is sender
    if (Owner(_campaign).owner() != msg.sender) {
      throw;
    }

    // prevent double registrations
    if (campaigns.length > 0) {
      if (campaigns[ids[_campaign]].addr == _campaign) {
        throw;
      }
    }

    _;
  }

  function register(address _campaign, address _interface) validRegistration(_campaign) public returns (uint256 campaignID) {
    // create campaign ID and increase campaigns array length by 1
    campaignID = campaigns.length++;

    // store camapign id
    ids[_campaign] = campaignID;

    // create new campaign, storing the campaign address, interface (if any)
    // and the time of registration
    campaigns[campaignID] = Campaign({
        addr: _campaign,
        abi: _interface,
        registered: now
    });

    // fire the campaign registered
    CampaignRegistered(_campaign, _interface, campaignID);
  }

  function idOf(address _campaign) constant public returns (uint256 campaignID) {
    return ids[_campaign];
  }

  function abiOf(uint256 _campaignID) constant public returns (address abi) {
    return campaigns[_campaignID].abi;
  }

  function registeredAt(uint256 _campaignID) constant public returns (uint256 registered) {
    return campaigns[_campaignID].registered;
  }

  function addressOf(uint256 _campaignID) constant public returns (address campaign) {
    return campaigns[_campaignID].addr;
  }

  function numCampaigns() constant public returns (uint256 count) {
    return campaigns.length;
  }

  struct Campaign {
    // the address of the campaign contract
    address addr;

    // the address of the interface contract
    address abi;

    // the UNIX block timestamp of when the campaign was registered
    uint256 registered;
  }

  Campaign[] public campaigns;
  mapping(address => uint) public ids;

  event CampaignRegistered(address _campaign, address _interface, uint256 _campaignID);
}
