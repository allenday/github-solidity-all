pragma solidity ^0.4.11;

/// @title Voting with delegation.
contract Ballot {
    // This declares a new complex type which will
    // be used for variables later.
    // It will represent a single voter.
    struct Voter {
        uint weight; // weight is accumulated by delegation
        bool voted;  // if true, that person already voted
        uint votedParty;   // index of the voted proposal
        uint votedCandidate;
    }

    // This is a type for a single proposal.
    struct Party {
        bytes32 partyName;   // short name (up to 32 bytes)
        uint partyVoteCount; // number of accumulated votes
    }

    struct Candidate {
        bytes32 candidateName;
        uint candidateVoteCount;
    }

    address public chairperson;
    uint electionEndTime = 0;
    bool electionHasStarted = false;

    uint blockNo;
    // This declares a state variable that
    // stores a `Voter` struct for each possible address.
    mapping(address => Voter) public voters;

    // A dynamically-sized array of structs.
    Party[] public parties;
    Candidate[] public candidates;

    /// Create a new ballot to choose one of `proposalNames`.
    function Ballot(bytes32[] partyNames, bytes32[] candidateNames) {
        chairperson = msg.sender;
        voters[chairperson].weight = 1;

        // For each of the provided proposal names,
        // create a new proposal object and add it
        // to the end of the array.
        for (uint i = 0; i < partyNames.length; i++) {
            // `Proposal({...})` creates a temporary
            // Proposal object and `proposals.push(...)`
            // appends it to the end of `proposals`.
            parties.push(Party({
                partyName: partyNames[i],
                partyVoteCount: 0
            }));
        }
        for (uint j = 0; j < candidateNames.length; j++) {  
            candidates.push(Candidate({
                candidateName: candidateNames[j],
                candidateVoteCount: 0
            }));
        }
    }
    // Function to start an election by setting end time in epoch-seconds
    function startElection(uint duration) {
        require(msg.sender == chairperson);
        electionEndTime = block.timestamp + duration;
        electionHasStarted = true;
    }

    // This function returns the total votes a candidate has received so far
    function totalVotesForParty(uint party) returns (uint numberOfVotes) {
        //require(electionHasStarted);
        //require(now > electionEndTime);
        numberOfVotes = parties[party].partyVoteCount;
    }
    // This function returns the total votes a candidate has received so far
    function totalVotesForCandidate(uint candidate) returns (uint numberOfVotes) {
        //require(electionHasStarted);
        //require(now > electionEndTime);
        numberOfVotes = candidates[candidate].candidateVoteCount;
    }

    // Give `voter` the right to vote on this ballot.
    // Hardcode addresses before election 
    function giveRightToVote(address voter) {
        require((msg.sender == chairperson) && !voters[voter].voted && (voters[voter].weight == 0));
        voters[voter].weight = 1;
    }

    /// Give your vote (including votes delegated to you)
    /// to proposal `proposals[proposal].name`.
    function vote(uint party, uint candidate) {
        // Check if election is still active 
        //require(electionHasStarted);
        //require(now < electionEndTime);
            Voter storage sender = voters[msg.sender];
            //require(!sender.voted); INCLUDE AFTER AUTHORIZING VOTERS 
            if (voters[msg.sender].voted) { 
                // Deduct the old vote 
                parties[sender.votedParty].partyVoteCount -= sender.weight;
                candidates[sender.votedCandidate].candidateVoteCount -= sender.weight;
                // Add the new vote 
                voters[msg.sender].votedParty = party;
                voters[msg.sender].votedCandidate = candidate;
                parties[party].partyVoteCount += sender.weight;
                candidates[candidate].candidateVoteCount += sender.weight;
            } else {
                sender.weight = 1;
                sender.voted = true;
                sender.votedParty = party;
                sender.votedCandidate = candidate;

                // If `proposal` is out of the range of the array,
                // this will throw automatically and revert all
                // changes.
                parties[party].partyVoteCount += sender.weight;
                candidates[candidate].candidateVoteCount += sender.weight;
            }
    }

    // Return the vote  -- should only be called by voter
    function getVotersPartyVote() constant // constant == read-only 
            returns (bytes32 partyTitle)
    {   

        // require(msg.sender = voteraddress);
        uint votedPartyVote = voters[msg.sender].votedParty;
        partyTitle = parties[votedPartyVote].partyName;
    }

    function getVotersCandidateVote() constant // constant == read-only 
            returns (bytes32 candidateTitle)
    {   
        Voter storage sender = voters[msg.sender];
        // require(msg.sender = voteraddress);
        uint votedCandidateVote = voters[msg.sender].votedCandidate;
        candidateTitle = candidates[votedCandidateVote].candidateName;
    }


    // Function removes vote to be called when they casted it live instead  
    // NOT TESTED! 
    //function removeVotersVote(address voter) {
      //  Voter storage sender = voters[voter];
        //proposals[sender.vote].voteCount -= 1;
        //delete voters[voter];
   // }
}