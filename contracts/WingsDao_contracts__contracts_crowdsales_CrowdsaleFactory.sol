pragma solidity ^0.4.8;

import "./BasicCrowdsale.sol";

contract CrowdsaleFactory {
  address public token;

  function CrowdsaleFactory(address _token) {
    token = _token;
  }

  function create(
      address _owner,
      address _parent,
      address _multisig,
      string _name,
      string _symbol,
      address _milestones,
      uint _price,
      uint _rewardPercent
    ) public returns (address) {
      var crowdsale = new BasicCrowdsale(
          _owner,
          _parent,
          _multisig,
          _name,
          _symbol,
          _milestones,
          _price,
          _rewardPercent
        );

      return crowdsale;
  }
}
