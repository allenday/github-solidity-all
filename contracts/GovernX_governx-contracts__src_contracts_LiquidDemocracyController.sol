pragma solidity ^0.4.16;

import "utils/Controller.sol";
import "utils/IMiniMeToken.sol";


contract LiquidDemocracyController is Controller {
    string public constant name = "LiquidDemocracyController";
    string public constant version = "1.0";

    uint256 public majority;
    uint256 public baseQuorum;
    uint256 public debatePeriod;
    uint256 public votingPeriod;
    uint256 public gracePeriod;
    uint256 public executionPeriod;

    mapping(address => mapping(uint256 => bool)) public delegated;
    mapping(address => mapping(uint256 => uint256)) public delegationWeight;
    mapping(uint256 => bool) public notAllowed;

    address public curator;
    IMiniMeToken public token;

  function LiquidDemocracyController(
    address _proxy,
    address _token,
    address _curator,
    uint256 _baseQuorum,
    uint256 _debatePeriod,
    uint256 _votingPeriod,
    uint256 _gracePeriod,
    uint256 _executionPeriod) {
    token = IMiniMeToken(_token);
    curator = _curator;
    baseQuorum = _baseQuorum;
    debatePeriod = _debatePeriod;
    votingPeriod = _votingPeriod;
    gracePeriod = _gracePeriod;
    executionPeriod = _executionPeriod;
    setProxy(_proxy);
  }

  function changeRules(
    uint256 _baseQuorum,
    uint256 _debatePeriod,
    uint256 _votingPeriod,
    uint256 _gracePeriod,
    uint256 _executionPeriod) public onlyProxy {
    baseQuorum = _baseQuorum;
    debatePeriod = _debatePeriod;
    votingPeriod = _votingPeriod;
    gracePeriod = _gracePeriod;
    executionPeriod = _executionPeriod;
  }

  function minimumQuorum() public constant returns (uint256) {
    return token.totalSupply() / baseQuorum;
  }

  function canPropose(address _sender, uint256 _proposalID) public constant returns (bool) {
    return token.balanceOf(_sender) > 0;
  }

  function canVote(address _sender, uint256 _proposalID) public constant returns (bool)  {
    return !hasVoted(_proposalID, _sender) && (token.balanceOfAtTime(_sender, voteTime(_proposalID)) > 0 && !delegated[_sender][_proposalID]) || _sender == curator;
  }

  function canExecute(address _sender, uint256 _proposalID) public constant returns (bool)  {
    return hasWon(_sender, _proposalID)
      && (block.timestamp < (momentTimeOf(_proposalID, 0) + debatePeriod + votingPeriod + gracePeriod + executionPeriod))
      && (block.timestamp > (momentTimeOf(_proposalID, 0) + debatePeriod + votingPeriod + gracePeriod));
  }

  function voteTime(uint256 _proposalID) public constant returns (uint256) {
    return momentTimeOf(_proposalID, 0) + debatePeriod + votingPeriod;
  }

  function votingWeightOf(address _sender, uint256 _proposalID, uint256 _index, uint256 _data) public constant returns (uint256)  {
    uint256 balanceAtVoteTime = token.balanceOfAtTime(_sender, voteTime(_proposalID));

    if(balanceAtVoteTime > 0 && !hasVoted(_proposalID, _sender) && !delegated[_sender][_proposalID])
      return balanceAtVoteTime + delegationWeight[_sender][_proposalID];
  }

  function hasWon(address _sender, uint256 _proposalID) public constant returns (bool)  {
    return (weightOf(_proposalID, 1) > minimumQuorum()) && !hasVoted(_proposalID, curator);
  }

  // delegation happens once and during the vote period
  function delegate(address _to, uint256 _proposalID) public {
    require(!hasVoted(_proposalID, msg.sender) && !delegated[msg.sender][_proposalID]);
    delegated[msg.sender][_proposalID] = true;
    delegationWeight[_to][_proposalID] += token.balanceOfAtTime(msg.sender, voteTime(_proposalID)) + delegationWeight[msg.sender][_proposalID];
  }
}
