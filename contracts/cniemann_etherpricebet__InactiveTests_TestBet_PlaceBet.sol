pragma solidity ^0.4.2;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/Bet.sol";

contract TestBet_PlaceBet {

    Bet bet;
    uint weiValue = 0;
    uint priceLevel = 12;
    uint betDate = 1476655200000;
    uint betDate2 = 1876655200000;

    function beforeAll() {
        bet = new Bet();
        bet.create.value(weiValue)(priceLevel);
    }

    function testPlaceBet() {
        bet.placeBet(betDate);
        Assert.equal(bet.bets(this), betDate, 'Bet is not 1476655200000');
    }

    function testChangeBet() {
        bet.placeBet(betDate2);
        Assert.equal(bet.bets(this), betDate2, 'Bet has not changed.');
    }
}
