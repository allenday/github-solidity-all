pragma solidity ^0.4.16;


// the interface for proposable systems
contract IProposable {
  function latestMomentOf(uint256 _pid, address _sender) public constant returns (uint256);
  function hasVoted(uint256 _proposalID, address _sender) public constant returns (bool);
  function numMomentsOf(uint256 _proposalID) public constant returns (uint256);
  function momentSenderOf(uint256 _proposalID, uint256 _momentID) public constant returns (address);
  function momentValueOf(uint256 _proposalID, uint256 _momentID) public constant returns (uint256);
  function momentTimeOf(uint256 _proposalID, uint256 _momentID) public constant returns (uint256);
  function momentBlockOf(uint256 _proposalID, uint256 _momentID) public constant returns (uint256);
  function momentNonceOf(uint256 _proposalID, uint256 _momentID) public constant returns (uint256);
  function weightOf(uint256 _proposalID, uint256 _position) public constant returns (uint256);
  function voteWeightOf(uint256 _pid, uint256 _mid) public constant returns (uint256);
  function votePositionOf(uint256 _pid, uint256 _mid) public constant returns (uint256);
  function hasExecuted(uint _proposalID) public constant returns (bool);
  function metadataOf(uint256 _proposalID) public constant returns (string);
  function numDataOf(uint256 _proposalID) public constant returns (uint256);
  function dataOf(uint256 _proposalID) public constant returns (bytes);
  function nonces(address) public constant returns (uint256) {}

  event ProposalMoment(address _sender, uint256 _momentID, uint256 _proposalID);
}
