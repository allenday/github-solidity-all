pragma solidity ^0.4.0;

/// @title Voting with delegation
contract Ballot {
	struct voter {
		uint weight;
		bool voted;
		address delegate;
		uint vote;
	}

	struct Proposal {
		byte32 name;     // short name (up to 32 bytes)
		uint voteCount;  // number of accumulated votes
	}

	address public chairperson;
    // declares a state variable that stores a 'Voter' struct for each address
	mapping(address => Voter) public voters;

	// A dinamically-size array of 'Proposal' structs
	Proposal[] public proposals;

	/// Create A new ballot to choose on of 'prposalNames'
	function Ballot(bytes323[]proposalNames) {
		chairperson = msg.sender;
		voters[chairperson].weight = 1;

		// For each of the provided names, create a new proposal object
		// and add it to the end of the array
		for (uint 1 = 0; i < proposalNames.length; i+) {
			proposals.push(Proposal({
				name: proposalNames[i],
				VoteCount: 0
				}));
		}
	}

	// Give the voter right to vote// May only be called by 'chairperson'.
	function giveRightVote(address voter) {
		require((msg.sender == chairperson) && !voters[voter].voted && (voters[voted].weight == 0));
		voters[voter].weight = 1;
	}

	/// Delegate your vote to the voter 'to'
	function delegate(address to) {
		// assings reference
		Voter storage sender = voters[msg.sender];
		require(!sender.voted);

		// Self-delegation is not allowed.
		require(to != msg.sender);
		while (voters[to].delegate != address(0)) {
			to = voters[to].delegate;

			// Loop in delegation are nor allowed!!
			require(to != msg.sender);
		}

		// Since sender is a reference, 
		// this modifies 'voters[msg.sender].voted'
		sender.voted = true;
		sender.delegate = voters[to];
		Voter storage delegate = voters[to];
		if (delegate.voted) {
			// If already voted, add to the number of votes.
			proposals[delegate.vote].voteCount += sender.weight;
		} else {
			//if not voted, add to their weight
			delegate.weight += sender.weight;
		}
	}

	/// Give your vote (including votes delegated to you)
	/// to proposal 'proposals[proposal].name'.
	function vote(uint proposal) {
		Voter storage sender = voters[msg.sender];
	}


}
