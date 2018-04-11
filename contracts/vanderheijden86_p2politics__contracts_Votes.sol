pragma solidity ^0.4.8;
contract Votes {

  struct Vote {
    address userAddress;
    uint proposalId;
    uint iteration;
    uint value;
    bool voteRevoked;
    string comment;
    uint timestamp;
  }

  Vote[] votes;
  mapping(bytes32 => bool) voted;

  event VoteCompleted(uint proposalId);
  function vote(uint proposalId, uint iteration, uint value, string comment) returns (bytes32) {
    if (voted[sha3(msg.sender, proposalId, iteration)]) {
      return "Already voted";
    }
    Vote memory vote;
    vote.userAddress = msg.sender;
    vote.proposalId = proposalId;
    vote.iteration = iteration;
    vote.value = value;
    vote.voteRevoked = false;
    vote.comment = comment;
    vote.timestamp = now;

    votes.push(vote);
    VoteCompleted(proposalId);
    voted[sha3(msg.sender, proposalId, iteration)] = true;
    return "Voted successfully.";
  }

  function getProposalVoteCount(uint proposalId, uint iteration) constant returns (uint) {
    uint count = 0;
    for (uint i = 0; i < votes.length; i++) {
      if(votes[i].proposalId == proposalId && votes[i].iteration == iteration) {
        count ++;
      }
    }
    return count;
  }


  function getProposalVote(uint proposalId, uint iteration, uint proposalIdIndex) constant returns (address, uint, uint, bool, string, uint) {
    uint matchCount = 0;
    for (uint i=0; i < votes.length; i++) {
      if (votes[i].proposalId == proposalId && votes[i].iteration == iteration) {
        matchCount++;
        if (matchCount - 1 == proposalIdIndex) {
          return (votes[i].userAddress, votes[i].proposalId, votes[i].value,
                  votes[i].voteRevoked, votes[i].comment, votes[i].timestamp);

        }
      }
    }
  }

  function getAcceptedAndRejectedVotes(uint proposalId, uint iteration) constant returns (uint, uint) {

    uint acceptedVotes = 0;
    uint rejectedVotes = 0;
    for (uint i = 0; i < votes.length; i++) {
      if (votes[i].proposalId == proposalId && votes[i].iteration == iteration ) {
        if (votes[i].value == 1) {
          acceptedVotes ++;
        } else {
          rejectedVotes ++;
        }
      }
    }

    return (acceptedVotes, rejectedVotes);
  }

  function _voteAs(address userAddress, uint proposalId, uint iteration, uint value, string comment) returns (bytes32) {
    Vote memory vote;
    vote.userAddress = userAddress;
    vote.proposalId = proposalId;
    vote.iteration = iteration;
    vote.value = value;
    vote.voteRevoked = false;
    vote.comment = comment;
    vote.timestamp = now;

    votes.push(vote);
    VoteCompleted(proposalId);

    return "Voted successfully.";
  }

}
