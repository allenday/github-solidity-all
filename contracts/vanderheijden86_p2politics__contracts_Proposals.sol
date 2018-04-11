pragma solidity ^0.4.8;
contract Proposals {

  Proposal[] proposals;
  mapping(uint => uint) proposalDepths;
  uint proposalCount;

  struct Proposal {
    uint id;
    uint iteration;
    string title;
    bytes32 domain;
    bytes32 category;
    bytes32 phase;
    string description;
    uint startDate;
    uint endDate;
    uint completed;
  }

  function Proposals() {
  }

  function newProposal(string title, bytes32 domain, bytes32 category, bytes32 phase,
                       string description, uint endDate, uint completed) returns (uint) {
    _setProposal(proposalCount, title, domain, category, phase, description, endDate, completed);
    return proposalCount;
  }

  function newIteration(uint id, string title, bytes32 domain, bytes32 category, bytes32 phase,
                       string description, uint endDate, uint completed) returns (uint) {
    _setProposal(id, title, domain, category, phase, description, endDate, completed);
    return proposalCount;
  }

  function getProposal(uint index) constant returns (uint, uint, string, bytes32, bytes32, bytes32, string, uint, uint, uint) {
    Proposal p = proposals[index];
    return (p.id, p.iteration, p.title, p.domain, p.category, p.phase, p.description, p.startDate, p.endDate, p.completed);
  }

  function getProposalByIdIteration(uint id, uint iteration) constant returns (uint, uint, string, bytes32, bytes32, bytes32, string, uint, uint, uint) {
    for (uint i = 0; i < proposalCount; i++ ) {
      if (proposals[i].id == id && proposals[i].iteration == iteration) {
        Proposal p = proposals[i];
        return (p.id, p.iteration, p.title, p.domain, p.category, p.phase, p.description, p.startDate, p.endDate, p.completed);
      }
    }
  }

  function getCount() constant returns (uint) {
    return proposalCount;
  }

  function _setProposal(uint id, string title, bytes32 domain, bytes32 category, bytes32 phase,
                        string description, uint endDate, uint completed) returns (uint) {
    proposals.push(Proposal(id, _getDepth(id), title, domain, category, phase, description, now, endDate, completed));
    proposalDepths[id]++;
    proposalCount++;
    return proposalCount;
  }

  function _getDepth(uint id) internal constant returns (uint) {
    return proposalDepths[id];
  }
}
