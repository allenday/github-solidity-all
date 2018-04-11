pragma solidity ^0.4.4;

/*
ERROR CODES

Error 1 = NO_PERMISSION
Error 2 = ALREADY_VOTED
Error 3 = INVALID_TOKEN
Error 99 = WRONG_STAGE
*/

contract Election {

// ############## EVENTS ##############

    event error(uint);
    event log(string);
    event voteEvent(string, uint);
    event candidateAdded(string, uint);
    event resultPublished(string);

// ############## STRUCTS ##############

    struct Candidate {
        string name;
    }
    
    struct Voter {
        address addr;
        string token;
        string vote;
        uint candidateId;
    }

    enum Stage {
        PRE_VOTING,
        VOTING,
        PROCESSING,
        RESULT
    }

// ############## FIELDS ##############

    // contract owner becomes admin
    address public admin;
    Stage public currentStage = Stage.PRE_VOTING;

    // name of the election, e.g. "BP 2016"
    string public name;
    Candidate[] public candidates;
    
    Voter[] public voters;
    uint public nrVotes = 0;

    string public result = "";
    string public privateKey = "";

// ############## PUBLIC FUNCTIONS ##############

// TODO: add constant keyword to readonly functions. Remove return from write functions

    // Constructor of the contract
    function Election(string _name) {
        admin = msg.sender;
        name = _name;
    }

    // TODO: add modifier prevoting
    function addCandidate(string _name) requiresAdmin {
        candidates.push(Candidate({
            name: _name
        }));
        log("candidate added");
        candidateAdded(_name, candidates.length);
    }

    function startElection() preVoting {
        currentStage = Stage.VOTING;
    }

    function stopElection() voting {
        currentStage = Stage.PROCESSING;
    }
    
    function vote(string _token, string _vote, uint _candidateId) returns(uint) {
        if(currentStage != Stage.VOTING) { error(99); return 99; } // WRONG_STAGE
        if(alreadyVoted(_token)) { error(2); return 2; } // ALREADY_VOTED
        if(! isTokenValid(_token)) { error(3); return 3; } // INVALID_TOKEN

        // check vote validity

        voters.push(Voter({
            addr: msg.sender,
            token: _token,
            vote: _vote,
            candidateId: _candidateId
        }));
        nrVotes++;
        voteEvent(_token, nrVotes);
        return 0;
    }

/*
    function getResult() postVoting returns(uint[]) {
        uint[] memory votes;
        for(var i=0; i<voters.length; i++) {
            var candidateIndex = voteToCandidateIndex(i);
            if(candidateIndex >= 0) {
                votes[candidateIndex]++;
            }
        }
        return votes;
    }
*/

    function publishResult(string _result, string _privateKey) requiresAdmin {
        result = _result;
        privateKey = _privateKey;

        resultPublished(_result);
        currentStage = Stage.RESULT;
    }

// ############## MODIFIERS ##############

modifier requiresAdmin {
    if(msg.sender != admin) throw;
    _;
}

modifier preVoting {
    if(currentStage != Stage.PRE_VOTING) throw;
    _;
}

modifier voting {
    if(currentStage != Stage.VOTING) throw;
    _;
}

/*
modifier postVoting {
    if(currentStage != Stage.POST_VOTING) throw;
    _;
}
*/

// ############## PRIVATE FUNCTIONS ##############

    function alreadyVoted(string _token) returns(bool) {
        for(var i=0; i<voters.length; i++) {
            if(compareStrings(voters[i].token, _token) == 0) {
                return true;
            }
        }
        return false;
    }

    // checks if the token is valid and signed by the election registrar
    // TODO: implement (see https://gist.github.com/axic/5b33912c6f61ae6fd96d6c4a47afde6d)
    function isTokenValid(string _token) returns (bool) {
        return true;
    }

    function voteToCandidateIndex(uint _voterId) returns(uint) {
        return voters[_voterId].candidateId;
    }

    // from https://raw.githubusercontent.com/ethereum/dapp-bin/master/library/stringUtils.sol
    function compareStrings(string _a, string _b) returns (int) {
        bytes memory a = bytes(_a);
        bytes memory b = bytes(_b);
        uint minLength = a.length;
        if (b.length < minLength) minLength = b.length;
        //@todo unroll the loop into increments of 32 and do full 32 byte comparisons
        for (uint i = 0; i < minLength; i ++)
            if (a[i] < b[i])
                return -1;
            else if (a[i] > b[i])
                return 1;
        if (a.length < b.length)
            return -1;
        else if (a.length > b.length)
            return 1;
        else
            return 0;
    }

// ############## TESTS ###############

    function testFunc() returns (uint) {
        return 3;
    }

    function multiply(uint _n1, uint _n2) returns (uint) {
        return _n1 * _n2;
    }


    function testEvents() {
        error(1);
        log("this is a test");
    }

    function testEvent2() {

    }
}
