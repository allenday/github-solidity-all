contract Ballot {
	// This declares a new complex type which will
	// be used for variables later.
	// It will represent a single voter.
	struct Voter {
		uint weight;
		bool voted;
		address delegate;
		uint vote;
	}

	struct Proposal {
		bytes32 name;
		uint voteCount;
	}

	address public chairperson;
	mapping(address => Voter) public voters;
	Proposal[] public proposals;

	/// Create a new ballot to choose one of 'proposalNames.'
	function Ballot(bytes32[] proposalNames) {
		chairperson = msg.sender;
		voters[chairperson].weight = 1;
		for (uint i = 0; i < proposalNames.length; ++i) {
			proposals.push(Proposal({
				name: proposalNames[i],
				voteCount: 0
			}));
		}
	}

	function giveRightToVote(address voter) {
		if (msg.sender != chairperson || voters[voter].voted) {
			throw;
		}
		voters[voter].weight = 1;
	}

	/// Delegate your vote to the voter 'to.'
	function delegate(address to) {
		Voter sender = voters[msg.sender];
		if (sender.voted) {
			throw;
		}
		while (voters[to].delegate != address(0) && voters[to].delegate != msg.sender) {
			to = voters[to].delegate;
		}
		if (to == msg.sender) {
			throw;
		}
		sender.voted = true;
		sender.delegate = to;
		Voter delegate = voters[to];
		if (delegate.voted) {
			proposals[delegate.vote].voteCount += sender.weight;
		}
		else {
			delegate.weight += sender.weight;
		}
	}

	/// Give your vote (including votes delegated to you)
	/// to proposal 'proposals[proposal].name.'
	function vote(uint proposal) {
		Voter sender = voters[msg.sender];
		if (sender.voted) {
			throw;
		}
		sender.voted = true;
		sender.vote = proposal;
		proposals[proposal].voteCount += sender.weight;
	}

	/// @dev Computes the winning proposal taking all
	/// previous votes into account
	function winningProposal() constant returns (uint winningProposal) {
		uint winningVoteCount = 0;
		for (uint p = 0; p < proposals.length; ++p) {
			if (proposals[p].voteCount > winningVoteCount) {
				winningVoteCount = proposals[p].voteCount;
				winningProposal = p;
			}
		}
	}
}
