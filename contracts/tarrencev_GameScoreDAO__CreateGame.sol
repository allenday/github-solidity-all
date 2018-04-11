contract Games {

    uint public minVoters;
    uint public minConfirmTime;
    GameProposal[] public gameProposals;
    uint public numProposals;

    event ProposalAdded(uint proposalId, address proposer);
    event Voted(uint proposalId, bool inSupport, address voter);

    struct GameProposal {
        string awayParticipant;
        uint gameStartTime;
        string homeParticipant;
        uint numberOfVotes;
        bool openToVote;
        bytes32 proposalHash;
        bool proposalPassed;
        address proposer;
        Vote[] votes;
        mapping (address => bool) voted;
        uint minVotingTime;
    }

    struct Vote {
        bool inSupport;
        address voter;
    }

    function Games(uint minVoters_, uint minConfirmTime_) {
        minVoters = minVoters_;
        minConfirmTime = minConfirmTime_;
    }

    function proposeGame(string homeParticipant, string awayParticipant, uint gameStartTime, bytes transactionBytecode) returns (uint proposalId) {
        proposalId = gameProposals.length++;
        GameProposal p = gameProposals[proposalId];
        p.proposer = msg.sender;
        p.homeParticipant = homeParticipant;
        p.awayParticipant = awayParticipant;
        p.proposalHash = sha3(msg.sender, homeParticipant, awayParticipant, gameStartTime, transactionBytecode);
        p.gameStartTime = gameStartTime;
        p.openToVote = true;
        p.proposalPassed = false;
        p.numberOfVotes = 0;
        p.minVotingTime = now + minConfirmTime * 1 minutes;

        ProposalAdded(proposalId, msg.sender);
        numProposals = proposalId + 1;
    }

    function vote(uint proposalId, bool inSupport) returns (uint voteId) {
        GameProposal p = gameProposals[proposalId];
        if (p.voted[msg.sender] == true) throw;

        voteId = p.votes.length++;
        p.votes[voteId] = Vote({ inSupport: inSupport, voter: msg.sender });
        p.voted[msg.sender] = true;
        p.numberOfVotes = voteId + 1;
        Voted(proposalId,  inSupport, msg.sender);
    }

    function executeGameProposal(uint proposalId, bytes transactionBytecode) returns (int result) {
        GameProposal p = gameProposals[proposalId];
        /* Check if the proposal can be executed */
        if (now < p.minVotingTime  /* has the voting deadline arrived? */
            || !p.openToVote        /* has it been already executed? */
            ||  p.proposalHash != sha3(p.proposer, p.homeParticipant, p.awayParticipant, p.gameStartTime, transactionBytecode)) /* Does the transaction code match the proposal? */
            throw;

        // Create game contract
    }
}
