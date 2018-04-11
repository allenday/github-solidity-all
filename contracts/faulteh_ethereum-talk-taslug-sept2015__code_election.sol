/* My first foray into a Dapp for this talk */

contract mortal {
	/* owner of the contract */
	address owner;

	/* initialisation - set owner */
	function mortal() { owner = msg.sender; }

	/* owner can kill the contract */
	function kill() { if (msg.sender == owner) suicide(owner); }
}

contract election is mortal {
	/* Some events */
	event UserRegistered(address user);
	event UserVoted(address user, uint sel);

	/* define what the greeter will say */
	string question;
	
	/* array of possible answers */
	string[3] selections;

	/* results tally */
	uint[3] results;

	/* List of tokens in circulation */
	mapping (address => uint) votes;
	mapping (address => uint) registered;


	/* initialising - set the greeting */
	function election(string _question, string s1, string s2, string s3) public {
		question = _question;
		owner = msg.sender;
		selections[0] = s1;
		selections[1] = s2;
		selections[2] = s3;
	}

	/* register a participant to vote (they receive a token) */
	function register() public returns (bool) {
		if (registered[msg.sender] == 0) {
			registered[msg.sender] = 1;
			votes[msg.sender] = 1;
			UserRegistered(msg.sender);
			return true;
		} else {
			return false;	/* can't register more than once */
		}
	}

	/* the vote function */
	function vote(uint selection) public returns (bool) {
		/* Check if they are registered to vote and haven't voted already */
		if (registered[msg.sender] == 1 && votes[msg.sender] == 1) {
			/* check if valid decision */
			if (selection >= 0 && selection < selections.length) {
				votes[msg.sender] = 0;	/* user has voted */
				results[selection] += 1;
				UserVoted(msg.sender, selection);
				return true;
			}
		}
		return false;
	}

	/* get function - get the question */
	function getQuestion() constant returns (string) {
		return question;
	}

	/* get function - get the selections */
	function getSelection(uint selection) constant returns (string) {
		return selections[selection];
	}

	/* get function - get the results */
	function getResult(uint selection) constant returns (uint) {
		return results[selection];
	}
}
