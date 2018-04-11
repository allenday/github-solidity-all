pragma solidity ^0.4.14;

// 
// ballot
// 

contract User { 
     function vote(Ballot ballot, uint8 proposal){
        ballot.vote(proposal);
    }
    function() payable{}
}

contract TestBallot {
    
    // fallback 100 ether
    function () payable {}
    
    Ballot public ballot;
    
    function test0Vote() returns (uint8) {
        ballot = new Ballot(2);
        ballot.vote(1);
        ballot.vote(0);
        ballot.vote(1);
        uint8 winId = ballot.winningProposal();
        require(winId == 1);
        return winId;
    }

    function test1Vote() returns (uint8) {
        ballot = new Ballot(2);
        ballot.vote(1);
        ballot.vote(0);
        ballot.vote(1);
        // who win 2:2
        ballot.vote(0);
        uint8 winId = ballot.winningProposal();
        require(winId == 1);
        return winId;
    }

    function test2ContractVote() returns (uint8) {
        ballot = new Ballot(2);
        User alice = new User();
        User bob = new User();
        ballot.giveRightToVote(alice);
        ballot.vote(1);
        alice.vote(ballot, 0);
        ballot.vote(0);
        bob.vote(ballot, 0);
        uint8 winId = ballot.winningProposal();
        require(winId == 0);
        return winId;
    }
}

contract Ballot {

    struct Voter {
        uint weight;
        bool voted;
        uint8 vote;
        address delegate;
    }
    struct Proposal {
        uint voteCount;
    }

    address chairperson;
    mapping(address => Voter) voters;
    Proposal[] proposals;

    /// Create a new ballot with $(_numProposals) different proposals.
    function Ballot(uint8 _numProposals) {
        chairperson = msg.sender;
        voters[chairperson].weight = 1;
        proposals.length = _numProposals;
    }

    /// Give $(voter) the right to vote on this ballot.
    /// May only be called by $(chairperson).
    function giveRightToVote(address voter) {
        if (msg.sender != chairperson || voters[voter].voted) return;
        voters[voter].weight = 1;
    }

    /// Delegate your vote to the voter $(to).
    function delegate(address to) {
        Voter storage sender = voters[msg.sender]; // assigns reference
        if (sender.voted) return;
        while (voters[to].delegate != address(0) && voters[to].delegate != msg.sender)
            to = voters[to].delegate;
        if (to == msg.sender) return;
        sender.voted = true;
        sender.delegate = to;
        Voter storage delegateTo = voters[to];
        if (delegateTo.voted)
            proposals[delegateTo.vote].voteCount += sender.weight;
        else
            delegateTo.weight += sender.weight;
    }

    /// Give a single vote to proposal $(proposal).
    function vote(uint8 proposal) {
        Voter storage sender = voters[msg.sender];
        if (sender.voted || proposal >= proposals.length) return;
        sender.voted = true;
        sender.vote = proposal;
        proposals[proposal].voteCount += sender.weight;
    }

    function winningProposal() constant returns (uint8 _winningProposal) {
        uint256 winningVoteCount = 0;
        for (uint8 proposal = 0; proposal < proposals.length; proposal++)
            if (proposals[proposal].voteCount > winningVoteCount) {
                winningVoteCount = proposals[proposal].voteCount;
                _winningProposal = proposal;
            }
    }
}