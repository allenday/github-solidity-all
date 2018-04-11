// #include_once "base/api.sol"
// #include_once "base/action.sol"
// #include_once "base/permissions.sol"
// #include_once "base/persistentProtectedContract.sol"
// #include_once "democracy/ownersDb.sol"

/// @title Direct Democracy Smart Contract Governance
/// @author ryepdx
contract DirectDemocracy is PermissionsProvider, PersistentProtectedContract {
    uint public quorum;
    uint8 public quorumPercent;
    uint public marginForVictory;
    uint8 public marginForVictoryPercent;
    uint public minimumVotingWindow;
    uint public maximumVotingWindow;

    uint VOTING_WINDOW_MIN = 600; // 10 minutes
    bytes32 OWNERS_DB = "OwnersDb";

    mapping (address => Proposal) public proposals;
    mapping (address => bool) permittedAction;

    enum Vote {
        Null, Yes, No, Abstain
    }

    struct Proposal {
        uint timestamp;
        mapping (address => Vote) votes;
        uint numVotes;
        address proposedAction;
    }
    
    /// @notice Create a DirectDemocracy voting smart contract.
    /// Before it will begin working properly, the address of a
    /// smart contract implementing the ApiProvider interface
    /// must be passed to setApiAddress, and the "`OWNERS_DB`"
    /// contract entry on the ApiProvider must set to the address
    /// of a smart contract implementing the OwnersDb interface.
    /// @dev Implements the PermissionsProvider interface.
    function DirectDemocracy() {
        quorum = 1;
        quorumPercent = 60;
        marginForVictory = 0;
        marginForVictoryPercent = 0;
    }

    /// @notice Check if the contract referred to should be
    /// permitted to modify contracts relying on this contract
    /// for protection.
    /// @param action
    /// @return True if the contract was voted on and passed,
    /// or if the DirectDemocracy contract isn't set up yet.
    function permitted(address action) returns (bool result) {
        return permittedAction[action]
        || api == 0x0
        || ApiProvider(api).contracts(OWNERS_DB) == 0x0;
    }

    /// @notice Add a new voting owner to the contract.
    /// May only be successfully called from an Action
    /// contract that was voted on and passed.
    /// @param owner
    /// @return True if owner was added, false otherwise. 
    function addOwner(address owner) returns (bool added) {
        var dbAddress = ApiProvider(api).contracts(OWNERS_DB);
        if (dbAddress == 0x0 || !permittedSender()) return false;
     
        added = OwnersDb(dbAddress).addOwner(owner);

        if (added) {
            _updateMargins();
        }
    }
 
    /// @notice Remove a voting owner from the contract.
    /// May only be successfully called from an Action
    /// contract that was voted on and passed.
    /// @param owner
    /// @return True if owner was removed, false otherwise. 
    function removeOwner(address owner) returns (bool removed) {
        var dbAddress = ApiProvider(api).contracts(OWNERS_DB);
        var db = OwnersDb(dbAddress);
        var iter = db.owners(owner);

        if (dbAddress == 0x0 || iter == 0x0 || !permittedSender()) {
            return false;
        }

        if (!db.removeOwner(owner)) return false;

        Proposal proposal;
        var numOwners = db.numOwners();

        for (uint i=0; i < numOwners; i+=1) {
            proposal = proposals[iter];
            iter = db.owners(iter);

            if (proposal.proposedAction == 0x0) continue;

            if (proposal.votes[owner] != Vote.Null) { 
                delete proposal.votes[owner];
                proposal.numVotes -= 1;
            }
        }

        delete proposals[owner];
        _updateMargins();

        return true;
    }

    /// @notice Propose an Action contract for execution.
    /// If the Action contract is passed, it will have full
    /// permission to modify any contracts protected by this
    /// contract, including this contract itself. Each owner
    /// can only have one Action contract proposed at any
    /// given time.
    /// @dev One way the limit on proposals can be raised is
    /// by turning the proposals mapping into a two-dimensional
    /// mapping of owners to block timestamps to proposals.
    /// In fact, this is how it was done in an earlier version:
    /// https://github.com/ryepdx/etherlab/blob/386b3c5db36ac40
    /// 25408025b6f601110d36cdae4/root.sol
    /// After switching from single-action, hardcoded proposals
    /// to Action contracts, though, the loss of efficiency due
    /// to maintaining a two-dimensional mapping just didn't
    /// seem worth it anymore.
    /// @param proposedAction
    function proposeAction(address proposedAction) {
        var dbAddress = ApiProvider(api).contracts(OWNERS_DB);
        var db = OwnersDb(dbAddress);
        if (db.owners(msg.sender) == 0x0
            || Action(proposedAction).owner() != address(this)) {
            return;
        }
        
        var proposal = proposals[msg.sender];
        proposal.timestamp = block.timestamp;
        proposal.proposedAction = proposedAction;
        proposal.votes[msg.sender] = Vote.Yes;
        proposal.numVotes = 1;
    }

    /// @notice Withdraw from voting the Action contract you
    /// had previously proposed.
    function withdrawProposedAction() {
        _removeProposal(msg.sender);
    }

    /// @notice Set the minimum voter turnout necessary for
    /// an Action contract to pass. May only be successfully
    /// called from an Action contract that was passed.
    /// @param percent Voter turnout percentage as an
    /// unsigned integer. Cannot be greater than 100.
    function setQuorumPercent(uint8 percent) {
        if (percent > 100 || !permittedSender()) return;
        quorumPercent = percent;
        _updateMargins();
    }

    /// @notice Set the percentage margin by which votes
    /// in either direction must beat votes in the
    /// other direction in order for an Action contract
    /// to pass. May only be successfully called from an
    /// Action contract that was voted on and passed.
    /// @param percent Required margin percentage as an
    /// unsigned integer. Cannot be greater than 100.
    function setMarginForVictoryPercent(uint8 percent) {
        if (percent > 100 || !permittedSender()) return;
        marginForVictoryPercent = percent;
        _updateMargins();
    }

    /// @notice Set the minimum number of seconds voting
    /// must remain open before a final count is made.
    /// May only be successfully called from an Action
    /// contract that was voted on and passed.
    /// @dev Time is judged by block timestamps and thus
    /// cannot be considered precise.
    /// @param minimumWindow
    function setMinimumVotingWindow(uint minimumWindow) {
        if (!permittedSender()) return;
        minimumVotingWindow = minimumWindow;
    }

    /// @notice Set the maximum number of seconds voting
    /// may remain open before a final count is made.
    /// Cannot be set to anything between 0 and
    /// `VOTING_WINDOW_MIN`, exclusive. If set to 0,
    /// voting will remain open until quorum is reached
    /// and the margin required for victory has been
    /// achieved by either side.
    /// May only be successfully called from an Action
    /// contract that was voted on and passed.
    /// @dev Time is judged by block timestamps and thus
    /// cannot be considered precise.
    /// @param maximumWindow
    function setMaximumVotingWindow(uint maximumWindow) {
        if ((maximumWindow < VOTING_WINDOW_MIN && maximumWindow != 0)
            || !permittedSender()) {
            return;
        }
        maximumVotingWindow = maximumWindow;
    }

    /// @notice Remove all proposed Action contracts. May
    /// only be successfully called from an Action contract
    /// that was voted on and passed.
    /// @dev Calls "remove" on each Action contract as they
    /// are removed.
    function wipeProposedActions() {
        if (!permittedSender()) return;

        var dbAddress = ApiProvider(api).contracts(OWNERS_DB);
        var db = OwnersDb(dbAddress);
        var iter = db.ownersTail();
        var numOwners = db.numOwners();

        for (uint i=0; i < numOwners; i += 1) {
            if (proposals[iter].proposedAction != 0x0) {
                Action(proposals[iter].proposedAction).remove();
                delete proposals[iter];
            }
            iter = db.owners(iter);
        }
    }

    /// @notice Vote on `action`, proposed by `owner`.
    /// @dev We require the action parameter to make sure the
    /// voter knows exactly what they are voting on. Otherwise
    /// it might be possible to pull a "bait & switch" using
    /// the "withdrawProposal" function, which could be
    /// effective if there are only two or three owners.
    /// @param owner The owner who proposed the Action.
    /// @param action The Action contract being voted on.
    /// @param vote A Vote value.
    function vote(address owner, address action, Vote vote) {
        var proposal = proposals[owner];

        if (action == 0x0
            || proposal.proposedAction != action
            || vote == Vote.Null) {
            return;
        }        

        if (maximumVotingWindow == 0
            || block.timestamp <= (proposal.timestamp + maximumVotingWindow)) {

            if (proposal.votes[msg.sender] == Vote.Null) {
                proposal.numVotes += 1;
            }

            proposal.votes[msg.sender] = vote;
        }

        if (block.timestamp > (proposal.timestamp + minimumVotingWindow)) {
            var outcome = _checkVotes(owner);
 
            if (outcome == Vote.Null) return;

            if (outcome == Vote.Yes) {
                permittedAction[proposal.proposedAction] = true;
                Action(proposal.proposedAction).execute();
                delete permittedAction[proposal.proposedAction];
            }
            _removeProposal(owner);
        }
    }

    /// @notice Send `amount` wei to `recipient`.
    /// May only be successfully called from an Action
    /// contract that was voted on and passed.
    /// @param recipient
    /// @param amount
    function spend(address recipient, uint amount) {
        if (!permittedSender()) return;
        recipient.send(amount);
    }

    /// @notice Delete this contract and all its proposed
    /// Action contracts from the blockchain.
    function remove() returns (bool result) {
        if (!permittedSender()) return false;
        wipeProposedActions();
        return super.remove();
    }

    function _removeProposal(address owner) private {
        if (proposals[owner].proposedAction == 0x0) return;
        Action(proposals[owner].proposedAction).remove();
        delete proposals[owner];
    }

    function _updateMargins() private {
        var numOwners = OwnersDb(ApiProvider(api).contracts(OWNERS_DB)).numOwners();
        quorum = (numOwners * 100) / quorumPercent;
        marginForVictory = (numOwners * 100) / marginForVictoryPercent;
    }

    function _checkVotes(address owner) private returns (Vote result) {
        var proposal = proposals[owner];
        if (proposal.numVotes < quorum) {
            return Vote.Null;
        }

        uint yesTally = 0;
        uint noTally = 0;
        var db = OwnersDb(ApiProvider(api).contracts(OWNERS_DB));
        var numOwners = db.numOwners();
        var iter = db.ownersTail();
        
        for (uint i=0; i < numOwners; i+=1) {
            iter = db.owners(iter);

            if (proposal.votes[iter] == Vote.Abstain || proposal.votes[iter] == Vote.Null) {
                continue;
            }

            if (proposal.votes[iter] == Vote.Yes) {
                yesTally += 1;
            } else {
                noTally -= 1;
            }
        }

        if (noTally > yesTally && (noTally - yesTally) >= marginForVictory) {
            return Vote.No;

        } else if (yesTally > noTally && (yesTally - noTally) >= marginForVictory) {
            return Vote.Yes;
        }

        return Vote.Null;
    }
}
