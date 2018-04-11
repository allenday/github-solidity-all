contract Auction {
	event AuctionClosed (uint highestBid);

	address public creator;

	function Auction () {
		creator = msg.sender;
	}

	function closeAuction (uint someRandomBid) {
		if (msg.sender == creator) {
			AuctionClosed (someRandomBid);
			return;
		}
		throw;
	}

}

contract Voting {
	struct Voter {
		bool hasVoted;
		uint weight;
	}

	struct Proposal {
		string author;
		string description;
		uint id;
		uint votes;
	}

	uint universalProposalId;

	address public chairperson;

	mapping (address => Voter) public voters;

	Proposal[] public proposals;

	event newVoter (address voterAddress);

	event fuckoff (uint x);

	function Voting () {
		chairperson = msg.sender;
		universalProposalId = 0;
		voters [chairperson] = Voter ({
			hasVoted: false,
			weight: 1
		});
		newVoter (chairperson);
	}

	function addProposal (string author, string desc) {
		proposals.push (Proposal ({
			author: author,
			description: desc,
			id: universalProposalId++,
			votes: 0
		}));
	}

	function castVote (uint id) {
		if (voters [msg.sender].weight > 0) {
			proposals [id].votes += 20;
			voters [msg.sender].weight--;
		}
	}

	function chairBalance () returns (uint bal) {
		return chairperson.balance;
	}

	function c () {
		Proposal ({
			author: 'ragahv',
			description: 'ddd',
			id: 190,
			votes: 19
		});
	}

}