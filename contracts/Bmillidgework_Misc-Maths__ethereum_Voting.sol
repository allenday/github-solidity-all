pragma solidity ^0.4.18;

contract Voting {
	

	// mapping is equibalent to an associative array of hash. the key of the mapping is 

	mapping (bytes32 => uint8) public votesReceived;

	// we pass in an array of bytes32 to the construvtor to store the list of candidates

	bytes32[] public candidateList;

	/* this is the constructor which will be called once you deploy the contract to the blockchain. when we deploy the contract, we will pass an array of candidates who will be contesting ni the eleciton */

	function Voting(bytes32[] candidateNames) public {
		candidateList = candidateNames;	
	}


	//this functoinreturns total votes a candidate has received so far

	function totalVotesFor(bytes32 candidate) view public returns (uint8) {
		require(validCandidate(candidate));
		return votesReceived[candidate];
	}

	// this function increments total vote count for the specified candidate, it's equivalent to casting a vote

	function voteForCandidate(bytes32 candidate) public {
		require(validCandidate(candidate));
		votesReceived[candidate] +=1;
	}

	//checks to see if the candidate is in the list
	function validCandidate(bytes32 candidate) view public returns (bool) {
		for(uint i = 0; i<candidateList.length; i++) {
			if (candidateList[i] == candidate) {
				return true;
			}
		}
		return false;
	}
}
