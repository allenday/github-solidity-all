pragma solidity ^0.4.11;


contract Election {

    uint electionId = 0;
    uint startDate;
    uint endDate;
    uint answers; // for multiple choice

    struct Choice {
        uint choiceId;
        bytes32 name;
    }

    // struct that represents a voter
    struct Voter {
        // bool hasVoted;
        address voterAddress; // identifier of a voter
        bytes32[] vote;//Choice[] vote; // chosen option(s)
    }

    // state variable that stores a 'Voter' for each address
    mapping(address => Voter) public votes; 

    Voter[] public voters;

    // array of options/choices
    Choice[] public choices;

    function Election(bytes32[] choicesNames, uint elId, uint start, uint end) {
        electionId = elId;
        startDate = start;
        endDate = end;

        for (uint i = 0; i < choicesNames.length; i++) {
            Choice memory newChoice = Choice({
                choiceId: i,
                name: choicesNames[i]
            });
            choices.push(newChoice);
        }

    }

    /**
     * Add voter
     *
     * Make `targetVoter` a voter named `voterName`
     *
     * 
     */
    // function addVoter(address targetVoter, bytes32[] _vote) internal {
       
    //    Voter memory voter = Voter({ voterAddress: targetVoter, vote: _vote});
    //     // voters.length++;
    //     votes[targetVoter] = voter;
    //     voters.push(voter);
        
    // }

    


    function castVote(bytes32[] choiceVote) public returns(bool success) {
        Voter memory voter = Voter({ voterAddress: msg.sender, vote: choiceVote});
        // voters.length++;
        votes[msg.sender] = voter;
        voters.push(voter);

        return true;
        
        // Voter memory voter = voters[msg.sender];
        // from docs: 
        // If the argument of `require` evaluates to `false`,
        // it terminates and reverts all changes to
        // the state and to Ether balances. It is often
        // a good idea to use this if functions are
        // called incorrectly. But watch out, this
        // will currently also consume all provided gas
        // (this is planned to change in the future).
        // require(!sender.hasVoted);
        // sender.hasVoted = true;
        // voter.vote = choiceVote;

        // addVoter(msg.sender, choiceVote);

    }

    function getVoteCount() public constant returns(uint voteCount) {
      return voters.length;
  }

    function getVoter(uint index) public returns(bytes32[] choices) {
      return voters[index].vote;
    }


}