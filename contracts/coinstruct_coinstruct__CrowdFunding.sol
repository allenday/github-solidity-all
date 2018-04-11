pragma solidity ^0.4.4;

import "./Token.sol";
import "./AddressRegistry.sol";


contract CrowdFunding is Token {
    // The states of the state machine.
    enum State {
        CampaignCreated,
        CampaignStarted,
        EarlyRewardPeriodEnded,
        CampaignSucceeded,
        CampaignFailed
    }

    // The state of fund raising campaign.
    State public state;

    // The address registry of the investors.
    AddressRegistry public investorRegistry;

    // If the fund raising is successful, send the Ethers to this address.
    address public creator;

    // The funding goal in Ethers.
    uint public fundingGoal;

    // The funding minimum in Ethers.
    uint public fundingMinimum;

    // The campaign start time in UNIX timestamp.
    uint public campaignStartTime;

    // The early reward period end time in UNIX timestamp.
    uint public earlyRewardPeriodEndTime;

    // The deadline of the campaign in UNIX timestamp.
    uint public campaignDeadline;

    // The total number of coins to be issued.
    uint public __totalSupply;

    // The number of coins to be issued to the creator initially.
    uint public creatorsSupply;

    // The price of one coin in Ethers.
    uint public price;

    // The price of one coin in "Early Reward Period" in Ethers.
    uint public earlyRewardPrice;

    // The amount raised so far in Ethers.
    uint public amountRaised;

    // The mapping which maps an address to the number of Ethers it raised.
    mapping (address => uint256) public etherRaisedBy;

    // The mapping which maps an address to the number of coins it owns.
    mapping (address => uint256) public coinsOwnedBy;

    event GoalReached(address beneficiary, uint amountRaised);
    event FundTransfer(address backer, uint amount, bool isContribution);

    // State Machine Implementation Reference:
    // http://solidity.readthedocs.io/en/develop/common-patterns.html#state-machine
    modifier timedTransitions() {
        if (state == State.CampaignCreated && now >= campaignStartTime) {
            state = State.CampaignStarted;
        }
        if (state == State.CampaignStarted && now >= earlyRewardPeriodEndTime) {
            state = State.EarlyRewardPeriodEnded;
        }
        if (state == State.EarlyRewardPeriodEnded && now >= campaignDeadline) {
            if (amountRaised < fundingMinimum) {
                state = State.CampaignFailed;
            } else {
                state = State.CampaignSucceeded;
            }
        }
        _;
    }

    // Create Campaign
    function CrowdFunding(
        AddressRegistry _investorRegistry,
        address _creator,
        uint _fundingGoal,
        uint _fundingMinimum,
        uint _campaignStartTime,
        uint _earlyRewardPeriodEndTime,
        uint _campaignDeadline,
        uint _totalSupply,
        uint _creatorsSupply,
        uint _price,
        uint _earlyRewardPrice
    ) {
        state = State.CampaignCreated;
        investorRegistry = _investorRegistry;
        creator = _creator;
        fundingGoal = _fundingGoal * 1 ether;
        fundingMinimum = _fundingMinimum;
        if (_campaignStartTime == 0) {
            campaignStartTime = now;
        } else {
            campaignStartTime = _campaignStartTime;
        }
        if (_earlyRewardPeriodEndTime == 0) {
            earlyRewardPeriodEndTime = campaignStartTime;
        } else {
            earlyRewardPeriodEndTime = _earlyRewardPeriodEndTime;
        }
        campaignDeadline = _campaignDeadline;
        __totalSupply = _totalSupply;
        creatorsSupply = _creatorsSupply;
        price = _price * 1 ether;
        earlyRewardPrice = _earlyRewardPrice * 1 ether;
    }

    function() payable {
        invest();
    }

    // Cancel Campaign
    function cancel()
        timedTransitions
        returns (bool success)
    {
        if (msg.sender != creator) {
            return false;
        }
        if (state != State.CampaignCreated &&
                state != State.CampaignStarted &&
                state != State.EarlyRewardPeriodEnded) {
            return false;
        }
        state = State.CampaignFailed;
        return true;
    }

    // Launch Project
    function launch()
        timedTransitions
        returns (bool success)
    {
        if (msg.sender != creator) {
            return false;
        }
        if (state != State.CampaignStarted &&
                state != State.EarlyRewardPeriodEnded) {
            return false;
        }
        if (amountRaised < fundingMinimum) {
            return false;
        }
        state = State.CampaignSucceeded;
        return true;
    }

    // Invest
    function invest()
        payable
        timedTransitions
        returns (bool success)
    {
        if (!investorRegistry.isRegistered(msg.sender)) {
            return false;
        }
        if (state != State.CampaignStarted &&
                state != State.EarlyRewardPeriodEnded) {
            return false;
        }
        uint etherAmount = msg.value;
        uint coinCount;
        if (state == State.CampaignStarted) {
            coinCount = etherAmount / earlyRewardPrice;
        } else {
            coinCount = etherAmount / price;
        }
        if (coinsOwnedBy[creator] - coinCount < creatorsSupply ||
                coinsOwnedBy[creator] - coinCount > coinsOwnedBy[creator] ||
                coinsOwnedBy[msg.sender] + coinCount < coinsOwnedBy[msg.sender]) {
            return false;
        }
        etherRaisedBy[msg.sender] += etherAmount;
        amountRaised += etherAmount;
        coinsOwnedBy[creator] -= coinCount;
        coinsOwnedBy[msg.sender] += coinCount;
        return true;
    }

    // Refund
    // Withdrawal Implementation Reference:
    // http://solidity.readthedocs.io/en/develop/common-patterns.html#withdrawal-from-contracts
    function refund()
        returns (bool success)
    {
        if (!investorRegistry.isRegistered(msg.sender)) {
            return false;
        }
        if (state != State.CampaignFailed) {
            return false;
        }
        uint amount = etherRaisedBy[msg.sender];
        if (!msg.sender.send(amount)) {
            etherRaisedBy[msg.sender] = amount;
            return false;
        }
        return true;
    }

    // This function implements the Token interface.
    function totalSupply()
        constant
        returns (uint256 supply)
    {
        return __totalSupply;
    }

    // This function implements the Token interface.
    function balanceOf(address _owner)
        constant
        returns (uint256 balance)
    {
        return coinsOwnedBy[_owner];
    }

    // Transfer Coin
    // This function implements the Token interface.
    function transfer(address _to, uint256 _value)
        returns (bool success)
    {
        if (!investorRegistry.isRegistered(msg.sender)) {
            return false;
        }
        if (state != State.CampaignSucceeded) {
            return false;
        }
        if (coinsOwnedBy[msg.sender] >= _value &&
                coinsOwnedBy[_to] + _value >= coinsOwnedBy[_to]) {
            coinsOwnedBy[msg.sender] -= _value;
            coinsOwnedBy[_to] += _value;
            Transfer(msg.sender, _to, _value);
            return true;
        } else {
            return false;
        }
    }

    // This function throws directly since this token does not support allowance.
    // This function implements the Token interface.
    function transferFrom(address _from, address _to, uint256 _value)
        returns (bool success)
    {
        throw;
    }

    // This function throws directly since this token does not support allowance.
    // This function implements the Token interface.
    function approve(address _spender, uint256 _value)
        returns (bool success)
    {
        throw;
    }

    // This function throws directly since this token does not support allowance.
    // This function implements the Token interface.
    function allowance(address _owner, address _spender)
        constant
        returns (uint256 remaining)
    {
        throw;
    }
}
