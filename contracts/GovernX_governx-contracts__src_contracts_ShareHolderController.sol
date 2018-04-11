// to be used with ElectedBoardController
// liquid democracy multi-class shareholder board with elections for board members

pragma solidity ^0.4.16;

import "utils/IProxy.sol";
import "utils/IMiniMeToken.sol";
import "utils/ControllerExtended.sol";


contract ShareHolderController is ControllerExtended {
  string public constant name = "ShareHolderController";
  string public constant version = "1.0";

  uint256 public majority;
  uint256 public baseQuorum;
  uint256 public debatePeriod;
  uint256 public votingPeriod;
  uint256 public gracePeriod;
  uint256 public executionPeriod;

  uint256 public electionDate = block.timestamp + (24 weeks);
  uint256 public electionDuration = 2 weeks;
  uint256 public electionOffset = 24 weeks;
  uint256 public electionBaseQuorum = 2;

  mapping(address => mapping(uint256 => bool)) public delegated;
  mapping(address => mapping(uint256 => uint256)) public delegationWeight;
  mapping(uint256 => bool) public notAllowed;

  address public electedBoard;
  uint256[] public ratios;
  address[] public tokens;

  function ShareHolderController(
    address _proxy,
    address[] _tokens,
    uint256[] _ratios,
    address _electedBoard,
    uint256 _baseQuorum,
    uint256 _electionBaseQuorum,
    uint256 _debatePeriod,
    uint256 _votingPeriod,
    uint256 _gracePeriod,
    uint256 _executionPeriod) public {
    tokens = _tokens;
    ratios = _ratios;
    electedBoard = _electedBoard;
    baseQuorum = _baseQuorum;
    debatePeriod = _debatePeriod;
    votingPeriod = _votingPeriod;
    gracePeriod = _gracePeriod;
    executionPeriod = _executionPeriod;
    electionBaseQuorum = _electionBaseQuorum;
    setProxy(_proxy);
  }

  function changeElection(
    uint256 _electionDate,
    uint256 _electionDuration,
    uint256 _electionOffset) public onlyProxy {
    electionDate = _electionDate;
    electionDuration = _electionDuration;
    electionOffset = _electionOffset;
  }

  function changeVariables(address[] _tokens,
    uint256[] _ratios,
    address _electedBoard,
    address _proxy,
    uint256 _baseQuorum,
    uint256 _electionBaseQuorum,
    uint256 _debatePeriod,
    uint256 _votingPeriod,
    uint256 _gracePeriod,
    uint256 _executionPeriod) public onlyProxy {
    tokens = _tokens;
    ratios = _ratios;
    electedBoard = _electedBoard;
    proxy = IProxy(_proxy);
    baseQuorum = _baseQuorum;
    debatePeriod = _debatePeriod;
    votingPeriod = _votingPeriod;
    gracePeriod = _gracePeriod;
    executionPeriod = _executionPeriod;
    electionBaseQuorum = _electionBaseQuorum;
  }

  function shareHolderBalanceOfAtTime(address _sender, uint256 _time) public constant returns (uint256 balance) {
    for (uint256 i = 0; i < tokens.length; i++)
      balance += IMiniMeToken(tokens[i]).balanceOfAtTime(_sender, _time) / ratios[i];
  }

  function totalTokenSupply() public constant returns (uint256 totalSupply) {
    for (uint256 i = 0; i < tokens.length; i++)
      totalSupply += IMiniMeToken(tokens[i]).totalSupply();
  }

  function minimumElectionQuorum() public constant returns (uint256) {
    return totalTokenSupply() / electionBaseQuorum;
  }

  function minimumQuorum() public constant returns (uint256) {
    return totalTokenSupply() / baseQuorum;
  }

  function canPropose(address _sender, uint256 _proposalID) public constant returns (bool) {
    return shareHolderBalanceOfAtTime(_sender, block.timestamp) > 0;
  }

  function canVote(address _sender, uint256 _proposalID) public constant returns (bool)  {
    return !hasVoted(_proposalID, _sender) && (shareHolderBalanceOfAtTime(_sender, voteTime(_proposalID)) > 0 && !delegated[_sender][_proposalID]);
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
    uint256 balanceAtVoteTime = shareHolderBalanceOfAtTime(_sender, voteTime(_proposalID));

    if(balanceAtVoteTime > 0 && !hasVoted(_proposalID, _sender) && !delegated[_sender][_proposalID])
      return balanceAtVoteTime + delegationWeight[_sender][_proposalID];
  }

  function hasWon(address _sender, uint256 _proposalID) public constant returns (bool)  {
    bool isElection = isElectionPeriodProposal(_proposalID);
    bool onlyElectionSignatures = true;
    bool onlyElectedBoard = true;
    bool usesElectedBoard = false;

    bytes4 electSig = bytes4(sha3("addMember(address)"));
    bytes4 unelectSig = bytes4(sha3("removeMember(address)"));

    for(uint256 c;
          c < numDataOf(_proposalID);
          c += lengthOf(_proposalID, c) + (20 + 32 + 32)) {
      bytes4 dataSig = signatureOf(_proposalID, c);
      address dest = destinationOf(_proposalID, c);

      if (dest == electedBoard) usesElectedBoard = true;
      if (!isElection && dest == electedBoard) return false;
      if (dest != electedBoard) onlyElectedBoard = false;
      if (dataSig != electSig && dataSig != unelectSig) onlyElectionSignatures = false;
    }

    if (isElection && onlyElectionSignatures && onlyElectedBoard && weightOf(_proposalID, 0) > minimumElectionQuorum()) return true;
    if (!isElection && usesElectedBoard) return false;

    return (weightOf(_proposalID, 0) > minimumQuorum() && !usesElectedBoard);
  }

  // delegation happens once and during the vote period
  function delegate(address _to, uint256 _proposalID) public {
    require(!hasVoted(_proposalID, msg.sender) && !delegated[msg.sender][_proposalID]);
    delegated[msg.sender][_proposalID] = true;
    delegationWeight[_to][_proposalID] += shareHolderBalanceOfAtTime(msg.sender, voteTime(_proposalID)) + delegationWeight[msg.sender][_proposalID];
  }

  function resetElectionPeriod() public {
    if (block.timestamp > electionDate + electionDuration)
      electionDate = electionDate + electionDuration + electionOffset;
  }

  function isElectionPeriod() public constant returns (bool) {
    return (block.timestamp >= electionDate && block.timestamp <= electionDate + electionDuration);
  }

  function isElectionPeriodProposal(uint256 _proposalID) public constant returns (bool) {
    uint256 creationTime = momentTimeOf(_proposalID, 0);

    return (creationTime >= electionDate && creationTime <= electionDate + electionDuration);
  }
}
