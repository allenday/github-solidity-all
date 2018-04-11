contract Votes {

    struct Vote {
        uint userId;
        uint proposalId;
        uint value;
        bool voteRevoked;
        string comment;
        uint timestamp;
    }

event VoteCompleted(uint proposalId);
    function vote (address userAddress, uint proposalId, uint value, string comment) returns (bytes32) {
        Vote.userId = userAddress;
        Vote.proposalId = proposalId;
        Vote.value = value;
        vote.voteRevoked = false;
        vote.comment = comment;
        vote.timestamp = now;

        VoteCompleted(proposalId);
        return "Voted succesful";
    }
}
