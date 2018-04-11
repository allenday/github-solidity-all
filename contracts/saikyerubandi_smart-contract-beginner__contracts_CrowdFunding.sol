/*
  A simple CrowdFunding contract.
    Shows the usage of 'payable' function modifier, special variables-
    'msg.sender','msg.value' and events.
  */
pragma solidity ^0.4.11;

/** @title Counter */
contract CrowdFunding {

  struct Funder {
          address addr; //funding address
          uint amount; //funding amount
    }

  struct Campaign {
        address beneficiary; //address holding the amount
        uint goalAmount; //amount to be raised in Wei
        uint numFunders; //total number of funders
        uint amountRaised; //amount raised so far
        mapping (uint => Funder) funders;
    }

  mapping (uint => Campaign) campaigns ;
  uint numCampaigns= 0;

  //events that will be fired
  event newCampaignStarted(uint campaignID,uint goal);
  event newFundReceived(uint campaignID,uint numFunders,uint amount);
  event goalReached(uint campaignID);


  function newCampaign( address beneficiary,uint goal){

    //goal cannot not zero
  //  if(goal <= 0){revert();}

    campaigns[numCampaigns] =  Campaign(beneficiary,goal,0,0);
    newCampaignStarted(numCampaigns,goal);//log the event
    numCampaigns++;

  }

  /**
   *  Note: Struct type Campagin cannot be returned so flatten the structure as multiple returns
  */
  function getCampaign(uint ID) constant returns (address benefitiary,uint goalAmount,uint numFunders,uint amountRaised){

    Campaign storage campaign = campaigns[ID];
    return (campaign.beneficiary,campaign.goalAmount,campaign.numFunders,campaign.amountRaised);
  }

  /**
      Note: uses special variables msg.sender for sender's address
      and amount of Wei is retrieved from msg.value.

      without "payable" keyword here, the function will
      automatically reject all Ether/Wei sent to it.
  */
  function fundCampaign(uint ID) payable {

      //funding value cannot be zero
      if(msg.value <= 0) {revert();}

      Campaign storage campaign = campaigns[ID];
      campaign.funders[campaign.numFunders++] = Funder(msg.sender,msg.value);
      campaign.amountRaised += msg.value;

      //log events
      newFundReceived(ID,campaign.numFunders,msg.value);

      if(checkGoalReached(ID)){
        goalReached(ID);
      }
  }

  function checkGoalReached(uint ID) constant returns (bool goalReached){

      Campaign storage campaign = campaigns[ID];
      assert(campaign.beneficiary!=0);
      if(campaign.amountRaised>=campaign.goalAmount){ return true; }
      return false;
  }


}
