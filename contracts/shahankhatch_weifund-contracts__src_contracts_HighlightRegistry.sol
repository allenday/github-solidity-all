pragma solidity ^0.4.3;

import "Owner.sol";

contract HighlightRegistryInterface {
  /// @notice register the campaign
  /// @param _campaign the address of the campaign contract
  function register(address _campaign) public {}

  /// @notice unregister the campaign
  /// @param _campaign the address of the campaign contract
  function unregister(address _campaign) public {}
}

contract HighlightRegistry is Owner, HighlightRegistryInterface {

  function register(address _campaign) onlyowner public {
    activePicks[_campaign] = true;
    pickedCampaigns.push(_campaign);
  }

  function unregister(address _campaign) onlyowner public {
    activePicks[_campaign] = false;
  }

  mapping(address => bool) public activePicks;
  address[] public pickedCampaigns;
}
