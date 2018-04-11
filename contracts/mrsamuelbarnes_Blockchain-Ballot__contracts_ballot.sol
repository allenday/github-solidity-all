pragma solidity ^0.4.2;

// Blockchain Ballot Contract
contract Ballot {

  // Public variables of the ballot
  string public title;
  string public description;
  string public candidates;
  uint public candidatesCount;
  address[] public voters;
  mapping (address => bool) public hasVoted;
  uint[] public publicKeyN;
  uint[] public publicKeyG;
  uint[] public votes;

  // Contract constructor
  function Ballot(string _title, string _description, string _candidates, uint _candidatesCount, address[] _voters, uint[] _publicKeyN, uint[] _publicKeyG) {

    // Set the basic variables
    title = _title;
    description = _description;
    candidates = _candidates;
    candidatesCount = _candidatesCount;

    // Loop through each voter address
    uint index = 0;
    for (index = 0; index < _voters.length; index++) {

      // Add the address to the voters array
      voters.push(_voters[index]);

      // Initalise the voter has voted flag
      hasVoted[_voters[index]] = false;
    }

    // Loop through each chunk of the public key 'n'
    for (index = 0; index < _publicKeyN.length; index++) {

      // Add the chunk to the complete array
      publicKeyN.push(_publicKeyN[index]);
    }

    // Loop through each chunk of the public key 'g'
    for (index = 0; index < _publicKeyG.length; index++) {

      // Add the chunk to the complete array
      publicKeyG.push(_publicKeyG[index]);
    }
  }

  // Get the voters of the ballot
  function getVoters() constant returns (address[]) { return voters; }

  // Get the public key 'n' of the ballot
  function getPublicKeyN() constant returns (uint[]) { return publicKeyN; }

  // Get the public key 'g' of the ballot
  function getPublicKeyG() constant returns (uint[]) { return publicKeyG; }

  // Get the votes in the ballot
  function getVotes() constant returns (uint[]) { return votes; }

  // Vote in the ballot
  function executeVote(uint[] vote) returns (bool sucess) {

    // Get the address attempting to voters
    address sender = msg.sender;

    // Loop through each voter
    for (uint index = 0; index < voters.length; index++) {

      // Check if this voter is the sender
      if (sender == voters[index]) {

        // Check if this voter has already voted
        if(!hasVoted[sender]) {

          // Check the vote is of the correct length
          // Each vote is 2048 bits long represented in 8 256 bit integers
          if(vote.length == candidatesCount * 8) {

              // Loop through the votes
              for (index = 0; index < vote.length; index++) {

                // Add this vote
                votes.push(vote[index]);

                // Mark this voter as having now voted
                hasVoted[sender] = true;
              }

              // The vote action was successful
              return true;
          }
        }
      }
    }

    // Sender is not a valid voter
    return false;
  }
}
