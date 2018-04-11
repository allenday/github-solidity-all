pragma solidity ^0.4.6;
// We have to specify what version of compiler this code will compile with

contract BallotPreferential {
  
    struct Voter {
        uint weight;
        bool voted;
    }

    address public admin;
    bytes32[] public candidateList;
    mapping(address => Voter) public votersList;
    mapping (bytes32 => uint8) public votesForCandidates;
    mapping (bytes32 => bytes32[]) public secondPreferences;
    uint public totalVotes;
    bytes32[] private tmpCandidateList;
    bytes32[] private allWinners;
    bytes32[] private losers;
    mapping(address => uint8) public candidateSubmissionNumbers;
        //phase 0: registration. phase 1: voting. phase 2: calculating winner,
        //phase 3: end of election
    uint8 private phase;

  function BallotPreferential() {
      totalVotes = 0;
      phase = 0;
      admin = msg.sender;
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
  
  function addCandidate(bytes32 candidate) {
      if (phase == 0) {
          if (candidate == "") return;
          if (validCandidate(candidate)) return;
          if (candidateSubmissionNumbers[msg.sender] >= 5) return;
          candidateList.push(candidate);
          candidateSubmissionNumbers[msg.sender] += 1;
      }
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

  function vote(bytes32 firstPreference, bytes32 secondPreference) {
    if (phase == 1) {
        if (votersList[msg.sender].weight != 1 || votersList[msg.sender].voted) return;
        if (validCandidate(firstPreference) == false || validCandidate(secondPreference) == false) throw;
        totalVotes += 1;
        votersList[msg.sender].voted = true;
        votesForCandidates[firstPreference] += 1;
        if (firstPreference != secondPreference) {
            secondPreferences[firstPreference].push(secondPreference);
        }
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
  
  //Only use at the end of the election!! 
  function calculateWinner() returns (bytes32[]) {
      if (phase == 2 && msg.sender == admin) {
        uint maxVotes = 0;
        bool goingToSecondPreference = false;
         if (totalVotes == 0) return candidateList;
        while (true) {
            allWinners = new bytes32[](0);
            for (uint i = 0; i < candidateList.length; i++) {
                if (votesForCandidates[candidateList[i]] == maxVotes) {
                allWinners.push(candidateList[i]);
            } else if (votesForCandidates[candidateList[i]] > maxVotes) {
              allWinners = new bytes32[](0);
              maxVotes = votesForCandidates[candidateList[i]];
              allWinners.push(candidateList[i]);
          }
        }
      
      //go by second preference
        if (allWinners.length == candidateList.length && !goingToSecondPreference) {
          addSecondPreferences(allWinners, false);
          goingToSecondPreference = true;
        } else {
            if (maxVotes > (totalVotes/2) || candidateList.length == 2 || candidateList.length == 1 || goingToSecondPreference) {
                phase = 3;
                return allWinners;
            }
            getLastCandidates();
            removeCandidates();
            addSecondPreferences(losers, true);
        }
      }
      }
  }
  
  function getWinners() returns (bytes32[]) {
      if (phase == 3) {
          return allWinners;
      }
  }
  
  function getCandidateList() returns (bytes32[]) {
      return candidateList;
  }
  
  function getLastCandidates(){
    if (phase == 2) {
        if (candidateList.length == 0) return;
        if (candidateList.length == 1) {
            losers.push(candidateList[0]);
            return;
        }
    
        uint leastVotes = votesForCandidates[candidateList[0]];
      
        for (uint i = 0; i < candidateList.length; i++) {
            if (votesForCandidates[candidateList[i]] == leastVotes) {
                losers.push(candidateList[i]);
            } else if (votesForCandidates[candidateList[i]] < leastVotes) {
                losers = new bytes32[](0);
                leastVotes = votesForCandidates[candidateList[i]];
                losers.push(candidateList[i]);
            }
        }
    }
  }
  
  function addSecondPreferences(bytes32[] candidates, bool shouldDelete) {
      if (phase == 2 && msg.sender == admin) {
        for (uint i = 0; i < candidates.length; i++) {
            for (uint j = 0; j < secondPreferences[candidates[i]].length; j++) {
                if (validCandidate(secondPreferences[candidates[i]][j])) {
                    votesForCandidates[secondPreferences[candidates[i]][j]] += 1;
                } else if (shouldDelete) {
                    votesForCandidates[secondPreferences[candidates[i]][j]] = 0;
                }
            }
        }
      }
  }
  
  function removeCandidates() {
      if (phase == 2 && msg.sender == admin) {
        for (uint j = 0; j < losers.length; j++) {
            tmpCandidateList = new bytes32[](0);
            for (uint i = 0; i < candidateList.length; i++) {
                if (candidateList[i] != losers[j]) {
                    tmpCandidateList.push(candidateList[i]);
                }
            }
            votesForCandidates[losers[j]] = 0;
            candidateList = new bytes32[](tmpCandidateList.length);
            candidateList = tmpCandidateList;
        }
      }
  }
  
  function notIn(bytes32[] excludeList, bytes32 candidateName) returns (bool) {
      for (uint i = 0; i < excludeList.length; i++) {
          if (excludeList[i] == candidateName) {
              return false;
          }
      }
      return true;
  }
}