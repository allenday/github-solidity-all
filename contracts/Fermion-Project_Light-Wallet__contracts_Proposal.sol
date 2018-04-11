pragma solidity ^0.4.15;

contract Proposal {
    // This will represent a single voter.
    struct Voter {
        bool voted;  // if true, that person already voted
        uint vote;   // 0 for no, nonzero for yes
    }
    // This declares a state variable that
    // stores a `Voter` struct for each possible address.
    mapping(address => Voter) public voters;
    
    // public variables of the proposal
    address public chairperson;
    uint public yesCount;
    uint public noCount;
    string public proposalName;
    
    function Proposal(string name) {
        proposalName = name;
        chairperson = msg.sender;
        yesCount = 0;
        noCount = 0;
    }
    
    function vote(uint decision) {
        Voter storage sender = voters[msg.sender];
        // allows a voter to change their vote
        //  || decision != sender.vote
        require(!sender.voted || decision != sender.vote);
        
        // adjust the count if user has already voted
        if (sender.voted && decision == 0) {
            yesCount--;
        } else if (sender.voted && decision != 0) {
            noCount--;
        }
        
        sender.voted = true;
        sender.vote = decision;
        
        if (decision == 0) {
            noCount++;
        } else {
            yesCount++;
        }
    }

    function proposalPassed() constant
            returns (bool passed)
    {
        if (noCount >= yesCount) {
            return false;
        }
        return true;
    }
}
