pragma solidity ^0.4.3;

import "Owner.sol";


contract CampaignDataRegistryInterface {
  /// @notice call `register` to register your campaign with a specified data store
  /// @param _campaign the address of the crowdfunding campaign
  /// @param _data the data store of that campaign, potentially an ipfs hash
  function register(address _campaign, bytes _data) public;

  /// @notice call `storedDate` to retrieve data specified for a campaign address
  /// @param _campaign the address of the crowdfunding campaign
  /// @return the data stored in bytes
  function storedData(address _campaign) constant public returns (bytes dataStored);

  event CampaignDataRegistered(address _campaign);
}

contract CampaignDataRegistry is CampaignDataRegistryInterface {

  modifier senderIsCampaignOwner(address _campaign) {
    // if the owner of the campaign is the sender
    if (Owner(_campaign).owner() != msg.sender) {
      throw;
    }

    // otherwise, carry on with normal state changing logic
    _;
  }

  function register(address _campaign, bytes _data) senderIsCampaignOwner(_campaign) public {
    data[_campaign] = _data;
    CampaignDataRegistered(_campaign);
  }

  function storedData(address _campaign) constant public returns (bytes dataStored) {
    return data[_campaign];
  }

  mapping(address => bytes) data;
}
