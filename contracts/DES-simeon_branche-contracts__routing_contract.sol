contract Crowdsale {
    address[] public cold_wallets;
    uint public fundingGoal; uint public amountRaised; uint public deadline;
    mapping(address => uint256) public balanceOf;
    mapping(address => uint256) public fundingBalance;
    bool fundingGoalReached = false;
    bool crowdsaleClosed = false;
    event GoalReached(uint amountRaised);
    event FundTransfer(address backer, address beneficiary, uint amount);

    function Crowdsale(
        address[] coldWalletAddresses,
        uint fundingGoalInEthers,
        uint durationInMinutes
    ) {
        fundingGoal = fundingGoalInEthers * 1 ether;
        deadline = now + durationInMinutes * 1 minutes;
        /* we take a list of cold wallets in case of failure and  */
        for (uint i = 0; i < coldWalletAddresses.length; i ++) {
            cold_wallets.push(coldWalletAddresses[i]);
            fundingBalance[coldWalletAddresses[i]] = 0;
        }
    }

    /* The function without name is the default function that is called whenever anyone sends funds to a contract */
    function () {
        if (crowdsaleClosed) throw;
        uint amount = msg.value;
        balanceOf[msg.sender] += amount;
        amountRaised += amount;
        /* fund the cold wallet with least funds */
        address beneficiary = getBenificiary();
        fundingBalance[beneficiary] += amount;
        if(!beneficiary.send(amount))
            throw;
        if (amountRaised >= fundingGoal){
            fundingGoalReached = true;
            GoalReached(amountRaised);
            crowdsaleClosed = true;
        }
        FundTransfer(msg.sender, beneficiary, amount);
    }

    modifier afterDeadline() { if (now >= deadline) _ }

    /* checks if the goal or time limit has been reached and ends the campaign */
    function checkGoalReached() afterDeadline {
        if (amountRaised >= fundingGoal){
            fundingGoalReached = true;
            GoalReached(amountRaised);
        }
        crowdsaleClosed = true;
    }

    /* definitely better ways of finding min. Can we indexOf an array? */
    function getBenificiary() returns (address) {
        uint index;
        uint min = fundingBalance[cold_wallets[0]];
        for (uint i = 1; i < cold_wallets.length; i ++) {
            uint balance = fundingBalance[cold_wallets[i]];
            if(balance < min){
                index = i;
                min = balance;
            }
        }
        return cold_wallets[index];
    }
}
