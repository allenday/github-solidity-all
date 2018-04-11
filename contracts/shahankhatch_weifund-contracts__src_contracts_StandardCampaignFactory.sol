pragma solidity ^0.4.3;

import "StandardCampaign.sol";
import "PrivateServiceRegistry.sol";


contract StandardCampaignFactory is PrivateServiceRegistry {
  /// @notice create a new standard campaign contract
  /// @param _name the name of the campaign
  /// @param _expiry the expiry of the campaign as a UNIX timestamp
  /// @param _fundingGoal the funding goal of the campaign stating in wei
  /// @param _beneficiary the beneficiary account address of the camapign
  /// @return will return the address of the new StandardCampaign contract created
  function newStandardCampaign(string _name,
    uint256 _expiry,
    uint256 _fundingGoal,
    address _beneficiary) public returns (address _campaignAddress) {
    // create the new StandardCampaign contract
    _campaignAddress = address(new StandardCampaign(_name, _expiry, _fundingGoal, _beneficiary, msg.sender));

    // register the campaign contract address with the PrivateServiceRegistry register method
    register(_campaignAddress);
  }
}
