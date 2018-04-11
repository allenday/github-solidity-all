pragma solidity ^0.4.11;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import '../contracts/SafeMath.sol';
import '../contracts/Pausable.sol';
import '../contracts/PullPayment.sol';
import './RokToken.sol';
import "./Crowdsale.sol";


contract TestCrowdsaleLogic {
  using SafeMath for uint256;
  Crowdsale public ico = new Crowdsale();

  function testBonus() {
    uint value = 500;
    uint expected = value.div(10);
    uint bonus = ico.getBonus(value);
    Assert.equal(bonus, expected, "Error bonus");
  }

  function testCheckRokTeam() {
    uint value = 1000000;
    ico.setSavedBalanceToken(value);
    uint expected = ico.checkRokSold().mul(19).div(100);

    Assert.equal(ico.checkRokTeam(), expected, "bounty amount should be equal to  10 000 ROK");
  }

  function testPayTokens() {;
    ico.setEthBalance(this, 1000);
    ico.setRokBalance(this, 100);
    uint expected = ico.getRok().balanceOf(this).add(100);
    ico.payTokens();

    Assert.equal(ico.getRok().balanceOf(this), expected, "error not valid pay token");
  }

  function testCheckRokBounty() {
    uint value = 1000000;
    ico.setSavedBalanceToken(value);
    uint expected = ico.checkRokSold().div(100);

    Assert.equal(ico.checkRokBounty(), expected, "bounty amount should be equal to  10 000 ROK");
  }

  function testCheckRokSold() {
    uint expected = 1000000;
    ico.setSavedBalanceToken(expected);

    Assert.equal(ico.checkRokSold(), expected, "Saved balance token should be equal to 1 000 000 ROK");
  }

  function testPayTeam(){
    uint value = 100000;
    ico.setSavedBalanceToken(value);
    uint expected = ico.tokenBalance(ico.team()).add(ico.checkRokTeam());

    ico.payTeam();

    Assert.equal(ico.tokenBalance(ico.team()), expected, "Error, Team balance");
  }

  function testPayout(){
    uint value = 10000000;
    ico.setEthBalance(this, value);
    ico.setRokBalance(this, value);

    uint expectedEscrowBalance = ico.escrow().balance.add(ico.balance);
    uint expectedBountyBalance = ico.tokenBalance(ico.bounty()).add(ico.checkRokBounty());

    ico.payout();

    Assert.equal(ico.escrow().balance, expectedEscrowBalance, "Error, Escrow balance");
    Assert.equal(ico.tokenBalance(ico.bounty()), expectedBountyBalance, "Error, Bounty balance");
  }

}
