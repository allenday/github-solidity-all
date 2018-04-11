pragma solidity 0.4.16;

import "utils/IProposable.sol";


contract Proposable is IProposable {
  modifier isMoment (uint256 _proposalID) { recordMoment(msg.sender, msg.value, _proposalID); _; }

  struct Moment {
      address sender;
      uint256 nonce;
      uint256 time;
      uint256 value;
      uint256 block;
  }

  struct Vote {
    uint256 position;
    uint256 weight;
  }

  struct Proposal {
    bool executed;
    mapping(uint256 => uint256) weights;
    mapping(address => uint256) latest;
    mapping(uint256 => Vote) votes;
    string metadata;
    bytes data;
    Moment[] moments;
  }

  function recordMoment(address _sender, uint256 _value, uint256 _proposalID) internal {
    proposals[_proposalID].latest[_sender] = proposals[_proposalID].moments.length;
    ProposalMoment(_sender, proposals[_proposalID].latest[_sender], _proposalID);
    proposals[_proposalID].moments.push(Moment({
        sender: _sender,
        value: _value,
        time: block.timestamp,
        block: block.number,
        nonce: nonces[_sender]++
    }));
  }

  function hasVoted(uint256 _pid, address _sender) public constant returns (bool) {
    return (proposals[_pid].latest[_sender] > 0);
  }
  function latestMomentOf(uint256 _pid, address _sender) public constant returns (uint256) { return proposals[_pid].latest[_sender]; }
  function numMomentsOf(uint256 _pid) public constant returns (uint256) { return proposals[_pid].moments.length; }
  function momentSenderOf(uint256 _pid, uint256 _mid) public constant returns (address) { return proposals[_pid].moments[_mid].sender; }
  function momentValueOf(uint256 _pid, uint256 _mid) public constant returns (uint256) { return proposals[_pid].moments[_mid].value; }
  function momentTimeOf(uint256 _pid, uint256 _mid) public constant returns (uint256) { return proposals[_pid].moments[_mid].time; }
  function momentBlockOf(uint256 _pid, uint256 _mid) public constant returns (uint256) { return proposals[_pid].moments[_mid].block; }
  function momentNonceOf(uint256 _pid, uint256 _mid) public constant returns (uint256) { return proposals[_pid].moments[_mid].nonce; }
  function weightOf(uint256 _proposalID, uint256 _position) public constant returns (uint256) {
    return proposals[_proposalID].weights[_position];
  }
  function voteWeightOf(uint256 _pid, uint256 _mid) public constant returns (uint256) {
    return proposals[_pid].votes[_mid].weight;
  }
  function votePositionOf(uint256 _pid, uint256 _mid) public constant returns (uint256) {
    return proposals[_pid].votes[_mid].position;
  }
  function hasExecuted(uint _proposalID) public constant returns (bool) { return proposals[_proposalID].executed; }
  function metadataOf(uint256 _proposalID) public constant returns (string) { return proposals[_proposalID].metadata; }
  function numDataOf(uint256 _proposalID) public constant returns (uint256) { return proposals[_proposalID].data.length; }
  function dataOf(uint256 _proposalID) public constant returns (bytes) {
    return proposals[_proposalID].data;
  }

  uint256 public numProposals;
  mapping(address => uint256) public nonces;
  mapping(uint256 => Proposal) public proposals;
}
