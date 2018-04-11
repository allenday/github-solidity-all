pragma solidity ^0.4.11;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/Betting.sol";

contract TestBetting {
	Betting betting = Betting(DeployedAddresses.Betting());

	function testBetId() {
        uint returnedId = betting.getId();
        Assert.equal(returnedId, 0, "Bet ID should be 0");
    }

	function testBetAmount() {
        uint returnedAmount = betting.getAmount();
        Assert.equal(returnedAmount, 5, "Bet amount should be 5");
    }

    function testMakeBet() {
        uint index = betting.makeBet();
        Assert.equal(betting.getParticipant(index), this, "Bet participant should be recorded");
    }

    function testResetBet() {
        betting.makeBet();
        betting.makeBet();
        betting.resetBet();
        Assert.equal(betting.getNumber(), 0, "Bet participant should be reseted");
    }

    function testSettle() {
        betting.makeBet();
        address result = betting.settle();
        Assert.equal(result, this, "Should win when only has one participant");
    }
}
