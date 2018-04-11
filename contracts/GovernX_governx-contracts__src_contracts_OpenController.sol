pragma solidity ^0.4.16;

import "utils/Controller.sol";


contract OpenController is Controller {
  string public constant name = "OpenController";
  string public constant version = "1.0";

  function OpenController(address _proxy) public {
    setProxy(_proxy);
  }

  function canPropose(address _sender, uint256 _proposalID) public constant returns (bool) {
    return true;
  }

  function canVote(address _sender, uint256 _proposalID) public constant returns (bool)  {
    return true;
  }

  function canExecute(address _sender, uint256 _proposalID) public constant returns (bool)  {
    return hasWon(_sender, _proposalID);
  }

  function votingWeightOf(address _sender, uint256 _proposalID, uint256 _index, uint256 _data) public constant returns (uint256)  {
    return 1;
  }

  // ui methods
  function hasWon(address _sender, uint256 _proposalID) public constant returns (bool) {
    return weightOf(_proposalID, 1) >= 1; // has one yes vote
  }
}
