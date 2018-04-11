pragma solidity ^0.4.11;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import '../contracts/SafeMath.sol';
import '../contracts/Pausable.sol';
import '../contracts/PullPayment.sol';
import './RokToken.sol';
import "./Crowdsale.sol";


contract TestCrowdsale {
  using SafeMath for uint256;
  Crowdsale public ico = new Crowdsale();

  function testInitialCrowdsale() {
    address expectedescrow = 0x3A194f27F363aEAc457938B676862E096Ac4680F;
    address expectedbounty = 0x990c32833833e96AF574ec0E33C722a2f1FC7a5e;
    address expectedteam = 0xAeCCB34e07207cD1C7544FeeAd4405148b4951C0;
    uint expectedrateETH_USD = 1;
    uint expectedrateETH_ROK = expectedrateETH_USD.mul(1000);
    uint expectedmaxFundingGoal = expectedrateETH_USD.mul(100000);
    uint expectedminFundingGoal = expectedrateETH_USD.mul(18000);
    uint expectedstartDate = 1509534000;
    uint expecteddeadline = 1512126000;
    uint expectedsavedBalanceToken = 0;
    uint expectedsavedBalance = 0;

    Assert.equal(ico.escrow(), expectedescrow, "address escrow not valid");
    Assert.equal(ico.bounty(), expectedbounty, "address bounty not valid");
    Assert.equal(ico.team(), expectedteam, "address team not valid");
    Assert.equal(ico.rateETH_USD(), expectedrateETH_USD, "rateETH_USD not valid");
    Assert.equal(ico.rateETH_ROK(), expectedrateETH_ROK, "rateETH_ROK not valid");
    Assert.equal(ico.maxFundingGoal(), expectedmaxFundingGoal, "max funding goal not valid");
    Assert.equal(ico.minFundingGoal(), expectedminFundingGoal, "min funding goal not valid");
    Assert.equal(ico.startDate(), expectedstartDate, "start date not valid");
    Assert.equal(ico.deadline(), expecteddeadline, "deadline not valid");
    Assert.equal(ico.savedBalanceToken(), expectedsavedBalanceToken, "saved balance token initialisation not valid");
    Assert.equal(ico.savedBalance(), expectedsavedBalance, "saved balance eth initialisation not valid");
  }

  function testIsStarted(){
    Assert.equal(ico.isStarted(), false, "Error, the crowdsale is not yet started");
  }

  function testIsComplete() {
    Assert.equal(ico.isComplete(), false, "Error, the crowdsale is not completed");
  }

  function testTokenBalance(){
    uint expected = 100000000;
    Assert.equal(ico.tokenBalance(), expected, "Error, Crowdsale should have 100000000 ROK initially");
  }

  function testIsSuccessful(){
    Assert.equal(ico.isSuccessful(), false, "Error, Crowdsale is not successful");
  }

  function testCheckEthBalance() {
    address contributor = 0xe241ed8Fe29a6835D4d780f7cC1fb2b3Fb60614C;
    uint expected = 1000;
    ico.setEthBalance(contributor,expected);

    Assert.equal(ico.checkEthBalance(contributor), expected, "Contributor should have 1000 ETH");
  }

  function testCheckSavecEthBalance() {
    address contributor = 0xe241ed8Fe29a6835D4d780f7cC1fb2b3Fb60614C;
    uint expected = 1000;
    ico.setSavedEthBalance(contributor,expected);

    Assert.equal(ico.checkSavedEthBalance(contributor), expected, "Contributor should have 1000 ETH");
  }

  function testCheckRokBalance() {
    address contributor = 0xe241ed8Fe29a6835D4d780f7cC1fb2b3Fb60614C;
    uint expected = 1000;
    ico.setRokBalance(contributor,expected);

    Assert.equal(ico.checkRokBalance(contributor), expected, "Contributor should have 1000 ROK");
  }
}
