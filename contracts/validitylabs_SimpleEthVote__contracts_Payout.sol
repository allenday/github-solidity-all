pragma solidity ^0.4.10;

import './VoteFactory.sol';

contract Payout {
    VoteFactory public myVoteFactory;

    event PaidOutVoter(address voter, uint amount);

    function setVoteFactory(address voteFactoryAddress) {
        // allows corresponding voteFactory to be set exactly once
        // removed this from the constructor to allow for easier code verification on etherscan
        // (constructor arguments currently have to be hex encoded and padded)
        assert(myVoteFactory == address(0));
        myVoteFactory = VoteFactory(voteFactoryAddress);
    }

    mapping(uint => uint) payoutAmount; // payout per round
    mapping(address => mapping(uint => bool)) requestedPayout;

    function () payable {

        // if previous round is over:
        if (myVoteFactory.nextEndTime() < now) {
            uint numPolls = myVoteFactory.numPolls();
            setPayoutAmount();
            // pay out to all, unless we have too many voters (very expensive call that might run into block gas limit limitations)
            uint maxNumVotersToPayDirectly = 20;
            if (myVoteFactory.numVoters(numPolls) < maxNumVotersToPayDirectly) {
                uint len = myVoteFactory.numVoters(numPolls);
                for (uint c = 0; c < len; c++) {
                    payOutVoterById(c);
                }
            } else {
                // if we have too many voters, just pay out to self
                payOutVoterByAddress(msg.sender);
            }
        }
    }
    
    function setPayoutAmount() internal {
        // before attempting to pay out anyone we should set the total payout amount
        uint numPolls = myVoteFactory.numPolls();
        if (payoutAmount[numPolls] == 0)
            payoutAmount[numPolls] == this.balance;
    }

    function payOutVoterById(uint voterId) {
        setPayoutAmount();
        uint numPolls = myVoteFactory.numPolls();

        // check for array out of bounds
        assert(voterId < myVoteFactory.numVoters(numPolls));

        address voter = myVoteFactory.voter(numPolls, voterId);
        payOutVoterByAddress(voter);
    }

    function payOutVoterByAddress(address voter) {
        setPayoutAmount();
        uint numPolls = myVoteFactory.numPolls();
        assert(myVoteFactory.hasVoted(voter, numPolls));
        assert(!requestedPayout[voter][numPolls]);
        uint amount = payoutAmount[numPolls];
        if (voter.send(amount)) {
            requestedPayout[voter][numPolls] = true;
            PaidOutVoter(voter, amount);
        }
    }

    function getCurrentNumberOfVoters() constant returns (uint numVoters) {
        uint numPolls = myVoteFactory.numPolls();
        return myVoteFactory.numVoters(numPolls);
    }
}
