pragma solidity ^0.4.8;

import "./BasicMilestones.sol";

contract MilestonesFactory {
  address public token;

  function MilestonesFactory(address _token) {
    token = _token;
  }

  function create(address _timeManager, address _owner, bool _cap) public returns (address) {
      var milestones = new BasicMilestones(_timeManager, _owner, _cap);
      return milestones;
  }
}
