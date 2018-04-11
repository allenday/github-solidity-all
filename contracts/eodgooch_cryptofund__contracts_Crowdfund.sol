pragma solidity ^0.4.11;

contract Crowdfund {

  // cryptofund account
  struct Account {
    address uuid;
  }

  // campaign funder
  struct Funder {
    address uuid;
    uint amount;
    bool initialized;
  }

  // campaign
  struct Campaign {
    address beneficiary;// benefactor of the campaign
    uint fundingGoal;   // end goal
    uint numFunders;    // number of funders to the campaign
    uint amount;        // current amount backing campaign
    uint endDate;       // ending date time in seconds from epoch
    bool isActive;      // is the campaign active
    mapping (address => Funder) funders;
  }

  // utils
  address cryptofund;
  uint numCampaigns = 0;
  mapping (uint => Campaign) campaigns;

  // functionality
  // newCampaign starts a new cryptofund
  function newCampaign(address beneficiary, uint fundingGoal, uint endDate) returns (uint campaignID) {
	  campaignID = numCampaigns++; // campaignID is return variable
	  // Creates new struct and saves in storage. We leave out the mapping type.
	  campaigns[campaignID] = Campaign(beneficiary, fundingGoal, 0, 0, endDate, true);
  }

  // contribute to the campaign
  function contribute(uint campaignID) {
      Campaign c = campaigns[campaignID];
      if (c.isActive) {
      // if this is a new funder, create funder and assign to mapping
        if (c.funders[msg.sender].initialized) {
          c.numFunders++;
          c.funders[msg.sender] = Funder({uuid: msg.sender, amount: msg.value, initialized: true});
          c.amount += msg.value;
        } else {
          // otherwise update the funders total contribution
          Funder updatedFunder = c.funders[msg.sender];
          updatedFunder.amount = updatedFunder.amount + msg.value;
          c.funders[msg.sender] = updatedFunder;
        }
    }
  }

  // payout the beneficiary
  function payout(uint campaignID, address admin) payable {
    if (admin == cryptofund) {
      Campaign c = campaigns[campaignID];
      uint fee = c.fundingGoal / 100; // 1% fee
      c.amount = c.amount - fee;
      if (c.amount >= c.fundingGoal) {
        cryptofund.transfer(fee);
        c.beneficiary.transfer(c.amount);
      } else {
        // apply a refund

      }
      c.isActive = false;
    }
  }

  // remove the campaign (mark it unactive)
  function deleteCampaign(Campaign c) internal {
    c.isActive = false;
  }

}
