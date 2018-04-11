pragma solidity ^0.4.14;

// 
// structs http://solidity.readthedocs.io/en/develop/types.html#structs
// 
contract CrowdFunding {
    // Defines a new type with two fields.
    struct Funder {
        address addr;
        uint amount;
    }

    struct Campaign {
        address beneficiary;
        uint fundingGoal;
        uint numFunders;
        uint amount;
        mapping (uint => Funder) funders;
    }

    uint numCampaigns;
    mapping (uint => Campaign) campaigns;

    function newCampaign(address beneficiary, uint goal) returns (uint campaignID) {
        campaignID = numCampaigns++; // campaignID is return variable
        // Creates new struct and saves in storage. We leave out the mapping type.
        campaigns[campaignID] = Campaign(beneficiary, goal, 0, 0);
    }

    function contribute(uint campaignID) payable {
        Campaign storage c = campaigns[campaignID];
        // Creates a new temporary memory struct, initialised with the given values
        // and copies it over to storage.
        // Note that you can also use Funder(msg.sender, msg.value) to initialise.
        c.funders[c.numFunders++] = Funder({addr: msg.sender, amount: msg.value});
        c.amount += msg.value;
    }

    function checkGoalReached(uint campaignID) returns (bool reached) {
        Campaign storage c = campaigns[campaignID];
        if (c.amount < c.fundingGoal)
            return false;
        uint amount = c.amount;
        c.amount = 0;
        c.beneficiary.transfer(amount);
        return true;
    }
}

contract User {
    function contribute(CrowdFunding cf , uint campaignId, uint _amount) {
        cf.contribute.value(_amount)(campaignId);
    }
    function () payable {}
}

contract TestCrowdFunding {

    User alice =  new User();
    User bob = new User();

    function testGoalReached() returns (bool reached) {
        alice.transfer(50 ether);
        bob.transfer(50 ether);
        CrowdFunding cf = new CrowdFunding();
        uint cid = cf.newCampaign(this, 10 ether);
        require(!cf.checkGoalReached(cid));
        // 
        // send ether to another contract
        // address.func.value(amount)(arg1, arg2, arg3)
        cf.contribute.value(1 ether)(cid);
        require(!cf.checkGoalReached(cid));
        alice.contribute(cf,cid,5 ether);
        require(!cf.checkGoalReached(cid));
        bob.contribute(cf,cid,5 ether);
        return cf.checkGoalReached(cid);
        
        // 200 -50 -50 -1 +10 
        require(this.balance == 109 ether);
    }

    // deposite 200 ether
    function () payable {}
}
