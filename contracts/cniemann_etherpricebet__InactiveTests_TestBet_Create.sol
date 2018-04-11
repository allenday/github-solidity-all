pragma solidity ^0.4.2;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/Bet.sol";

contract TestBet_Create {

    Bet bet;
    uint weiValue = 0;
    uint priceLevel = 12;

    function beforeAll() {
        bet = new Bet();

        bet.create.value(weiValue)(priceLevel);
    }

    function testCreatePricelevelUsingNewContract() {
        Assert.equal(bet.pricelevel(), priceLevel, 'Pricelevel should be 12 $ now');
    }

    function testCreatePrizeUsingNewContract() {
        Assert.balanceIsZero(bet, 'Bet should have 10000000000000000000 wei now');
    }

}
