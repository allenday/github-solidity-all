pragma solidity ^0.4.4;

// This contract will keep track of voting for proposals.
// Owners of an ERC20 token will be allowed to vote according to their ownership stake.  
// The balance of tokens in addresses are locked in at contract creation time.
// At the end of the voting period, a tally can be called to finalize the votes.
// A minimum number of votes (threshold) must be made in order for the vote to finalize to a "true" outcome.
contract ProposalVote {
	
	mapping (address => uint) public balances;

	uint public yesVotes;
	uint public noVotes;
	uint public threshold;	

 	unint public votingStarts;
	unit public votingEnds;

	// The contract will be created with an initial list of addresses and balances from an ERC20 token.
	// Voting will only be valid for a period of time from when this contract is created.
	function ProposalVote(mapping (address => uint) initalBalances, unint votingTimeLength, uint minVoteThreshold) {

		// Save off the inital balances
		balances = initialBalances

		// Save off the start time of the voting for information only.
		votingStarts = now;

		// Calculate when the vote period ends
		votingEnds = now + votingTimeLength;

		// Save off the threshold
		threshold = minVoteThreshold;
	}

	// Allow a caller to vote yes or no on the current proposal
	// The voting window must be valid and the user must have a balance from the initial token list.
	function CastVote(bool votingYes){

		// Ensure we are in a valid voting window
		if( now >= votingEnds ){
			throw;
		}

		// Get the weight of the current voter based on number of tokens they own
		uint weight = balances[msg.sender];

		// Check to make sure they have a balance to vote with
		if(weight == 0){
			throw;
		}

		// Update their balance to show they have already voted
		balances[msg.sender] = 0;

		// Add the vote weights
		if(votingYes) {
			yesVotes += weight;
		} else {
			noVotes += weights;
		}
	}


	function GetOutcome returns (bool) {

		// Ensure the voting period has ended
		if ( now <= votingEnds ){
			throw;
		}

		// Ensure a quorum was reached by having a minimum number of votes over the threshold
		if( yesVotes + noVotes < threshold){

			// Not enough votes were cast to allow this to be finalized to "true"
			return false;
		}

		// Determine whether the outcome was decided yes or no
		return yesVotes > noVotes;
	}	
}
