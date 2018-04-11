pragma solidity ^0.4.2;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/Bet.sol";

contract TestBet_New {

    function testInitalBalanceUsingDeployedContract() {
        Bet bet = Bet(DeployedAddresses.Bet());
        Assert.balanceIsZero(bet, "Bet should have 0 ether initially");
    }

    function testInitalBalanceUsingNewContract() {
        Bet bet = new Bet();
        Assert.balanceIsZero(bet, "Bet should have 0 ether initially");
    }

}
