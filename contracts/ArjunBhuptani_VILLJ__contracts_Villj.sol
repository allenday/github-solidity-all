pragma solidity ^0.4.2;

// This is a crowdfunding contract to find creative solutios to challenging problems
// go us!

contract Villj {
	string appId;

	uint problemCount;
	uint solutionCount;
	uint votesCast;
	uint weiRaised;

	struct Problem {
		uint id;
		string name;
		string description;
		string imgUrl;
		string userName;
		address userAddress;
		string category;
		uint startTime;
		uint weiRaised;
		uint solutionCount;
	}

	struct Solution {
		uint problemId;
		uint id;
		string name;
		string description;
		string imgUrl;
		string userName;
		string fbId;
		address solver;
		uint weiRaised;
		uint timePosted;

	}

	struct Vote {
		uint problemId;
		uint solutionId;
		uint id;
		address voter;
		uint voteInWei;
	}

	Problem[] public problems;
	Solution[] public solutions;
	Vote[] public votes;


	function Villj() {
		problemCount = 0;
		solutionCount = 0;
		weiRaised = 0;
	}

	function getProblem(uint _problemId) returns(string, string, string, string, uint, uint, uint) {
		if (_problemId >= 0 && _problemId < problems.length) {
			return (
				problems[_problemId].name,
				problems[_problemId].description,
				problems[_problemId].imgUrl,
				problems[_problemId].category,
				problems[_problemId].startTime,
				problems[_problemId].weiRaised,
				problems[_problemId].solutionCount
			);
		} else {
			throw;
		}
	}

	function getSolution(uint _problemId, uint _solutionId) returns(string, string, string, string, string, uint) {
		if (_problemId >= 0 && _problemId < problems.length) {
			if (solutions[_solutionId].problemId == _problemId) {
				return (
					solutions[_solutionId].name,
					solutions[_solutionId].description,
					solutions[_solutionId].imgUrl,
					solutions[_solutionId].userName,
					solutions[_solutionId].fbId,
					solutions[_solutionId].weiRaised
				);
			} else {
				throw;
			}
		} else {
			throw;
		}
	}

	function addProblem(string _name, string _description, string _imgUrl, string _userName, string _category) payable returns(uint) {
		problemCount++;
		weiRaised = weiRaised + msg.value;

		problems.length++;
		problems[problems.length-1].id = (problems.length-1);
        problems[problems.length-1].name = _name;
        problems[problems.length-1].description = _description;
        problems[problems.length-1].imgUrl = _imgUrl;
        problems[problems.length-1].userName = _userName;
        problems[problems.length-1].userAddress = msg.sender;
        problems[problems.length-1].category = _category;
        problems[problems.length-1].solutionCount = 0;
        problems[problems.length-1].weiRaised = msg.value;

        problems[problems.length-1].startTime = now;

        return problems.length;
	}


	function addSolution(uint _problemId, string _name, string _description, string _imgUrl, string _userName, string _fbId) returns(uint) {
		if ((problems[_problemId].startTime + 12 weeks) > now ) { //problem is not over yet
			solutionCount++;
			problems[_problemId].solutionCount++;

			solutions.length++;
			solutions[solutions.length-1].id = (solutions.length-1);
	        solutions[solutions.length-1].problemId = _problemId;
	        solutions[solutions.length-1].name = _name;        
	        solutions[solutions.length-1].description = _description;
	        solutions[solutions.length-1].imgUrl = _imgUrl;
	        solutions[solutions.length-1].userName = _userName;
	        solutions[solutions.length-1].fbId = _fbId;
	        solutions[solutions.length-1].solver = msg.sender;
	        solutions[solutions.length-1].weiRaised = 0;
	        solutions[solutions.length-1].timePosted = now;

	        return solutions.length;

	    }
	}

	function castVote(uint _problemId, uint _solutionId) payable returns(uint) {
			votesCast++;
			weiRaised = weiRaised + msg.value;

			votes.length++;
			votes[votes.length-1].id = (votes.length-1);
			votes[votes.length-1].problemId = _problemId;
			votes[votes.length-1].solutionId = _solutionId;
			votes[votes.length-1].voter = msg.sender;
			votes[votes.length-1].voteInWei = msg.value;

			problems[_problemId].weiRaised += msg.value;
	        solutions[_solutionId].weiRaised += msg.value;

	        return votes.length;
	}


	function claimGrant(uint _problemId) returns(uint) {
		if ((problems[_problemId].startTime + 12 weeks) > now ) {
			//the problem is not over yet
			return 0;
		} else {
			//the problem is over (send all the things)

			//grab the solution with the most money
			Solution memory winner;
			winner.weiRaised = 0;
			for (uint i = 0; i < solutions.length; i++){
				if (solutions[i].problemId == _problemId) {
					if (solutions[i].weiRaised > winner.weiRaised) {
						winner = solutions[i];
					}
				}
			}

			//send all the wei recieved to that wallet
			if (!winner.solver.send(problems[_problemId].weiRaised))
				throw;

			return 1;
		}
	}

}
