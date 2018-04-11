pragma solidity ^0.4.11;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/CrowdFunding.sol";

contract TestCrowdFunding {

  uint public initialBalance = 10 ether;

  function testInitialBalance(){
    Assert.equal(this.balance,initialBalance,"Balance of this contract should be same as InitialBalance set");
  }

  function testStartNewCampaign() {
    CrowdFunding crowdFunding = CrowdFunding(DeployedAddresses.CrowdFunding());
    crowdFunding.newCampaign(msg.sender,100);
    var (beneficiary,goalAmount,numFunders,amountRaised)  = crowdFunding.getCampaign(0);

    Assert.equal(goalAmount,100,"A new campaign should have a fundingoal"); // in ether
    Assert.equal(beneficiary,msg.sender,"A new campaign should have a beneficiary");
  }

  function testFundACampaign() {

    CrowdFunding crowdFunding = CrowdFunding(DeployedAddresses.CrowdFunding());
    crowdFunding.newCampaign(msg.sender,100);
    crowdFunding.fundCampaign.value(1)(0);
    var (beneficiary,goalAmount,numFunders,amountRaised)  = crowdFunding.getCampaign(0);

    Assert.equal(numFunders,1,"number of funders not correct");
    Assert.isNotZero(amountRaised,"amount raised cannot be zero");
  }

  function testCampaignGoalReached() {
    CrowdFunding crowdFunding = CrowdFunding(DeployedAddresses.CrowdFunding());
    crowdFunding.newCampaign(msg.sender,10 ether);
    crowdFunding.fundCampaign.value(initialBalance)(0); //sets msg.value

    var (beneficiary,goalAmount,numFunders,amountRaised)  = crowdFunding.getCampaign(0);

    Assert.isTrue(crowdFunding.checkGoalReached(0),"goal should be met when sufficient amount raised");
  }


}
