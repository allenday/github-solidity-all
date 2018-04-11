pragma solidity ^0.4.11;

/*
	Initially from : https://github.com/vitiko/solidity-test-example/blob/master/contracts/Congress.sol
	Changed by : Jimmy Paris

	Changed to be accessible only for a liste of the members
	Members can propose new members who will be accepted or not by votations.

	Note that in this version the creator can add the first members in a inital period.

*/


import './MomentalyOwned.sol';

contract CongressOwned is MomentalyOwned {

		/* constants, variables and events */
		uint256 public constant  minimumQuorum = 3; // Minimum acceptation + rejection
		uint256 public constant debatingPeriod = 7 days; //minimal delay to close a votation
		uint256 public constant majorityMinPourcent = 67;
		uint256 public constant periodEnterProposal = 7 days; //minimal delay enter 2 proposals from the same sender

		Proposal[] public proposals;
		uint256 public numProposals;
		mapping (address => uint256) public timeLastProposal;
		mapping (address => uint256) public memberId;
		Member[] public members;

		event ProposalAdded(uint256 proposalID, address candidate, string candidateName);
		event Voted(uint256 proposalID, bool position, address voter, string justification);
		event ProposalTallied(uint256 proposalID, uint256 result, uint256 quorum, bool active);
		event MembershipChanged(address member, bool isMember);

    struct Proposal {
				uint256 id;
        address candidateAddress;
        string candidateName; //name of the candidate
        uint256 votingDeadline;
        bool executed;
        bool proposalPassed;
        uint256 numberOfVotes;
        uint256 currentResult;
        Vote[] votes;
        mapping (address => bool) voted;
    }

    struct Member {
        address member;
        string name;
        uint256 memberSince;
    }

    struct Vote {
        bool inSupport;
        address voter;
        string justification;
    }

    /* Modifier that allows only members */
    modifier onlyMembers(address addr) {
        require(memberId[addr] != 0);
        _;
    }

		/* Modifier that allows only not members */
    modifier onlyNotMembers(address addr) {
        require(memberId[addr] == 0);
        _;
    }
		    /* First time setup */
    function CongressOwned() {
        // It’s necessary to add an empty first member (as a sentinel)
        addMember(0, '');
        // and let's add the founder, to save a step later
        addMember(owner, 'founder');
    }

		function getMembersCount() constant returns (uint256){
			return members.length -1;
		}

    /*make a new member*/
    function addElectedMember(address targetMember, string memberName) onlyAfterQ1 onlyNotMembers(targetMember) private  {
        uint256 id;
        memberId[targetMember] = members.length;
        id = members.length++;
        members[id] = Member({member: targetMember, memberSince: now, name: memberName});
        MembershipChanged(targetMember, true);
    }

    /*make a new "early" member*/
    function addMember(address targetMember, string memberName) onlyOwner onlyNotMembers(targetMember) onlyInQ1 {
        uint256 id;
        memberId[targetMember] = members.length;
        id = members.length++;
        members[id] = Member({member: targetMember, memberSince: now, name: memberName});
				MembershipChanged(targetMember, true);
    }

    function removeMember(address targetMember) onlyOwner onlyInQ1 onlyMembers(targetMember) returns (bool){
			 	for (uint256 i = memberId[targetMember]; i<members.length-1; i++){
				 	 	members[i] = members[i+1];
			 	 }
			 	memberId[targetMember] = 0;
				balances[targetMember] = 0;
			 	delete members[members.length-1];
			 	members.length--;
				MembershipChanged(targetMember, false);
    }


    function getTime() constant returns (uint256){
        return now;
    }

    /* Function to create a new proposal */
    function newProposal( address candidateAddress,string candidateName) onlyAfterQ1 onlyMembers(msg.sender) onlyNotMembers(candidateAddress) returns (uint256 proposalID) {
				require(now >= timeLastProposal[msg.sender] + periodEnterProposal); //Sender did not make a proposal for a while
	  		timeLastProposal[msg.sender] = now;	//Update the time of the last proposal from the sender

				//Create a new proposal
	      proposalID = proposals.length++;						//Set the id of the new proposal and (after) increase the proposals array
	      Proposal storage p = proposals[proposalID];	//Set the pointer
				p.id = proposalID;													//Set the id of this proposal
	      p.candidateAddress = candidateAddress;			//Set the ETH address of the candidate
	      p.candidateName = candidateName;						//Set the candidate firm identifier
	      p.votingDeadline = now + debatingPeriod;		//Set the deadline of this proposal
	      p.executed = false;													//Set the proposal to unexecuted
	      p.proposalPassed = false;										//Set the result of the proposal to false (unused if not executed)

				//Vote for my own proposal
				Vote storage v = p.votes[p.votes.length++];			//Get a new vote structure
				v.voter = msg.sender;														//Set the voter
				v.inSupport = true;															//Set the stat of his vote (accepted or rejected)
				v.justification = "Creator's vote";	            //Set the justification
				p.voted[msg.sender] = true;											// Sender has voted for this proposal
	      p.numberOfVotes = 1;														//Set the count of votes
				p.currentResult = 1;														//Set the count of acceptations

				numProposals = proposalID +1;										//Update the number of proposals
			  ProposalAdded(proposalID, candidateAddress, candidateName);
	      return proposalID;
    }

    function vote(uint256 proposalID,bool supportsProposal,string justificationText) onlyAfterQ1 onlyMembers(msg.sender) returns (uint256 voteID) {
        Proposal storage p = proposals[proposalID]; // Get the proposal
        require(p.voted[msg.sender] == false);          // If has already voted, cancel

				Vote storage v = p.votes[p.votes.length++];			//Get a new vote structure
				v.voter = msg.sender;														//Set the voter
				v.inSupport = supportsProposal;									//Set the stat of his vote (accepted or rejected)
				v.justification = justificationText;						// Set the justification

        p.voted[msg.sender] = true;                     // Set this voter as having voted
        p.numberOfVotes++;                              // Increase the number of votes

        if (supportsProposal) {                         // If they support the proposal
            p.currentResult++;                          // Increase score
        }
        // Create a log of this event
        Voted(proposalID,  supportsProposal, msg.sender, justificationText);
        return p.numberOfVotes;
    }

    function executeProposal(uint256 proposalID) onlyAfterQ1 {
        Proposal storage p = proposals[proposalID];

        require(now >= p.votingDeadline); // Has the voting deadline arrived?
        require(!p.executed); // Has it been already executed or is it being executed?
        require(p.numberOfVotes  >=  minimumQuorum); //Has a minimum quorum?

        /* If difference between support and opposition is larger than margin */
        if ( p.currentResult * 100 / p.numberOfVotes >= majorityMinPourcent) {
            // Add the member
            addElectedMember(p.candidateAddress,p.candidateName);
            p.proposalPassed = true;
        } else {
            p.proposalPassed = false;
        }
				p.executed = true; //Note the proposal as executed
        ProposalTallied(proposalID, p.currentResult, p.numberOfVotes, p.proposalPassed); //Fire event
    }

		function getVoteFromProposal(uint256 idProposal, uint256 idVote) constant returns (address, bool, string) {
			Proposal memory p = proposals[idProposal];
			Vote memory v = p.votes[idVote];
    	return (v.voter, v.inSupport, v.justification);
		}
}
