pragma solidity ^0.4.0;

contract Poll {
    int constant FAVORABLE_VOTE = 1;
    int constant NOT_FAVORABLE_VOTE = -1;

    address owner;
    bool public started = false;
    int voteCount = 0;
    mapping(address => int) votes;

    enum Result { 
        Draw, 
        Favorable,
        NotFavorable
    }

    function Poll() {
        owner = msg.sender;
    }

    function start() {
        if (msg.sender == owner) {
            started = true;
        }
    }

    function stop() {
        if (msg.sender == owner) {
            started = false;
        }
    }

    function vote(bool favorable) {
        if (started && votes[msg.sender] == 0) {
            int voteValue = favorable ? FAVORABLE_VOTE : NOT_FAVORABLE_VOTE;
            votes[msg.sender] = voteValue;
            voteCount += voteValue;
        }
    }

    function result() constant returns (Result) {
        if (voteCount == 0) {
            return Result.Draw;
        }

        if (voteCount > 0) {
            return Result.Favorable;
        }

        return Result.NotFavorable;
    }
}