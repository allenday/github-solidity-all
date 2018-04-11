pragma solidity ^0.4.6;
// We have to specify what version of compiler this code will compile with

contract Ballot {
  
    struct Voter {
        uint weight;
        bool voted;
    }

    address public admin;
    bytes32[] public candidateList;
    mapping(address => Voter) public votersList;
    mapping(address => uint8) public candidateSubmissionNumbers;
    mapping (bytes32 => uint8) public votesForCandidates;
    bytes32[] private winners;
    //phase 0: registration. phase 1: voting. phase 2: calculate winner
    //phase 3: end of election
    uint8 private phase;
  
  function Ballot() {
      phase = 0;
      admin = msg.sender;
  }
  
  function addCandidate(bytes32 candidate) {
      if (phase == 0) {
          if (candidate == "") return;
          if (validCandidate(candidate)) return;
          if (candidateSubmissionNumbers[msg.sender] > 5) return;
          candidateList.push(candidate);
          candidateSubmissionNumbers[msg.sender] += 1;
      }
  }
  
   function getCandidateList() returns (bytes32[]) {
      return candidateList;
  }
  
  function startVoting() {
      if (msg.sender == admin) {
        phase = 1;
      }
  }
  
  function finishVoting() {
      if (msg.sender == admin) {
        phase = 2;
      }
  }
  
  function getPhase() returns (uint8) {
      return phase;
  }
  
  function addVoter(address voter) {
      if (phase == 0) {
        votersList[voter] = Voter({weight: 1, voted: false});
      }
  }

  function totalVotesFor(bytes32 candidate) returns (uint8) {
    if (validCandidate(candidate) == false) throw;
    return votesForCandidates[candidate];
  }

  function vote(bytes32 candidate) {
    if (phase == 1) {
        if (votersList[msg.sender].weight != 1 || votersList[msg.sender].voted) return;
        if (validCandidate(candidate) == false) throw;
        votesForCandidates[candidate] += 1;
        votersList[msg.sender].voted = true;
    }
  }

  function validCandidate(bytes32 candidate) returns (bool) {
    for(uint i = 0; i < candidateList.length; i++) {
      if (candidateList[i] == candidate) {
        return true;
      }
    }
    return false;
  }
  
  function calculateWinner() returns (bytes32[]) {
      if (phase == 2 && msg.sender == admin) {
        uint maxVotes = 0;
        for (uint i = 0; i < candidateList.length; i++) {
            if (votesForCandidates[candidateList[i]] == maxVotes) {
                winners.push(candidateList[i]);
            } else if (votesForCandidates[candidateList[i]] > maxVotes) {
                winners = new bytes32[](0);
                maxVotes = votesForCandidates[candidateList[i]];
                winners.push(candidateList[i]);
            }
        }
        phase = 3;
        return winners;
      } 
  }
  
  function getWinner() returns (bytes32[]) {
      if (phase == 3) {
          return winners;
      }
  }
}