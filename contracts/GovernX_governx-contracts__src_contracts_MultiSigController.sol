pragma solidity ^0.4.16;

import "utils/Controller.sol";
import "utils/MembershipRegistry.sol";


contract MultiSigController is Controller, MembershipRegistry {
  uint256 public required;

  string public constant name = "MultiSigController";
  string public constant version = "1.0";

  function MultiSigController(address _proxy, address[] _members, uint256 _required) public {
    for (uint256 m = 0; m < _members.length; m++)
      _addMember(_members[m]);

    required = _required;
    setProxy(_proxy);
  }

  function changeVariables(uint256 _required) onlyProxy {
    required = _required;
  }

  function canPropose(address _sender, uint256 _proposalID) public constant returns (bool) {
    return isMember(_sender);
  }

  function canVote(address _sender, uint256 _proposalID) public constant returns (bool)  {
    return isMember(_sender) && !hasVoted(_proposalID, _sender);
  }

  function canExecute(address _sender, uint256 _proposalID) public constant returns (bool)  {
    return isMember(_sender) && hasWon(_sender, _proposalID);
  }

  function votingWeightOf(address _sender, uint256 _proposalID, uint256 _position, uint256 _weight) public constant returns (uint256)  {
    if (isMember(_sender))
      return 1;
  }

  // extra methods for UI
  function hasWon(address _sender, uint256 _proposalID) public constant returns (bool) {
    uint256 voteYes = weightOf(_proposalID, 1);

    return voteYes >= required;
  }
}
