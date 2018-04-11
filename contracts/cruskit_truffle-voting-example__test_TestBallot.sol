pragma solidity ^0.4.2;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/Ballot.sol";

contract TestBallot {


    function testCreateBallotContract() {
        Ballot ballot = Ballot(DeployedAddresses.Ballot());

        uint winner = ballot.winningProposal();
        uint expected = 0;

        Assert.equal(winner, expected, "The winning proposal should be 0");
    }



}