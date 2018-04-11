pragma solidity ^0.4.16;

import "utils/IRules.sol";


contract DefaultRules is IRules {
  function canPropose(address _sender, uint256 _proposalID) public constant returns (bool) {
    return false;
  }

  function canVote(address _sender, uint256 _proposalID) public constant returns (bool)  {
    return false;
  }

  function canExecute(address _sender, uint256 _proposalID) public constant returns (bool)  {
    return false;
  }

  function votingWeightOf(address _sender, uint256 _proposalID, uint256 _position, uint256 _data) public constant returns (uint256)  {
    return 0;
  }

  function hasWon(address _sender, uint256 _proposalID) public constant returns (bool) {
    return false;
  }

  function hasFailed(address _sender, uint256 _proposalID) public constant returns (bool) {
    return false;
  }
}
