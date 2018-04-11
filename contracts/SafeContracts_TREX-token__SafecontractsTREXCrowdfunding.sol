pragma solidity ^0.4.0;

// Title SafecontractsTREXCrowdfunding.sol
import "AbstractSafecontractsTREXToken.sol";
import "AbstractSafecontractsTREXFund.sol";


// @title Crowdfunding contract - Implements crowdfunding functionality.
// @author Stefan George - <stefan.george@consensys.net>
// Customize @author Rocky Fikki - <rocky@fikki.net>
// Credit - https://github.com/ConsenSys/singulardtv-contracts

contract SafecontractsTREXCrowdfunding {

    /*
     *  External contracts
     */
    SafecontractsTREXToken public safecontractsTREXToken;
    SafecontractsTREXFund public safecontractsTREXFund;


    /*
     *  Constants
     */
    uint constant public CAP = 1000000000; // 1B tokens is the maximum amount of tokens
    uint constant public CROWDFUNDING_PERIOD = 4 weeks; // 1 month
    uint constant public TOKEN_LOCKING_PERIOD = 1 years; // 1 years
    uint constant public TOKEN_TARGET = 1050000; // 50000 Tokens more than the initial 100M.

    /*
     *  Enums
     */
    enum Stages {
        CrowdfundingGoingAndGoalNotReached,
        CrowdfundingEndedAndGoalNotReached,
        CrowdfundingGoingAndGoalReached,
        CrowdfundingEndedAndGoalReached
    }

    /*
     *  Storage
     */
    address public owner;
    uint public startDate;
    uint public fundBalance;
    uint public baseValue = 10000 szabo; // 0.0100 ETH
    uint public valuePerShare = baseValue; // 0.0100 ETH

    // investor address => investment in Wei
    mapping (address => uint) public investments;

    // Initialize stage
    Stages public stage = Stages.CrowdfundingGoingAndGoalNotReached;

    /*
     *  Modifiers
     */
    modifier noEther() {
        if (msg.value > 0) {
            throw;
        }
        _
    }

    modifier onlyOwner() {
        // Only owner is allowed to do this action.
        if (msg.sender != owner) {
            throw;
        }
        _
    }

    modifier minInvestment() {
        // User has to invest at least the ether value of one share.
        if (msg.value < valuePerShare) {
            throw;
        }
        _
    }

    modifier atStage(Stages _stage) {
        if (stage != _stage) {
            throw;
        }
        _
    }

    modifier atStageOR(Stages _stage1, Stages _stage2) {
        if (stage != _stage1 && stage != _stage2) {
            throw;
        }
        _
    }

    modifier timedTransitions() {
        uint crowdfundDuration = now - startDate;
        if (crowdfundDuration >= 25 days) {
            valuePerShare = baseValue * 2000 / 1000;
        }
        else if (crowdfundDuration >= 19 days) {
            valuePerShare = baseValue * 1750 / 1000;
        }
        else if (crowdfundDuration >= 13 days) {
            valuePerShare = baseValue * 1500 / 1000;
        }
        else if (crowdfundDuration >= 07 days) {
            valuePerShare = baseValue * 1250 / 1000;
        }
        else {
            valuePerShare = baseValue;
        }
        if (crowdfundDuration >= CROWDFUNDING_PERIOD) {
            if (stage == Stages.CrowdfundingGoingAndGoalNotReached) {
                stage = Stages.CrowdfundingEndedAndGoalNotReached;
            }
            else if (stage == Stages.CrowdfundingGoingAndGoalReached) {
                stage = Stages.CrowdfundingEndedAndGoalReached;
            }
        }
        _
    }

    /*
     *  Contract functions
     */
    // dev Validates invariants.
    function checkInvariants() constant internal {
        if (fundBalance > this.balance) {
            throw;
        }
    }

    // @dev Can be triggered if an invariant fails.
    function emergencyCall()
        external
        noEther
        returns (bool)
    {
        if (fundBalance > this.balance) {
            if (this.balance > 0 && !safecontractsTREXFund.trexdevshop().send(this.balance)) {
                throw;
            }
            return true;
        }
        return false;
    }

    // @dev Allows user to fund the campaign if campaign is still going and cap not reached. Returns share count.
    function fund()
        external
        timedTransitions
        atStageOR(Stages.CrowdfundingGoingAndGoalNotReached, Stages.CrowdfundingGoingAndGoalReached)
        minInvestment
        returns (uint)
    {
        uint tokenCount = msg.value / valuePerShare; // Token count is rounded down. Investment should be multiples of valuePerShare.
        if (safecontractsTREXToken.totalSupply() + tokenCount > CAP) {
            // User wants to buy more shares than available. Set shares to possible maximum.
            tokenCount = CAP - safecontractsTREXToken.totalSupply();
        }
        uint investment = tokenCount * valuePerShare; // Ether invested by backer.
        // Send change back to user.
        if (msg.value > investment && !msg.sender.send(msg.value - investment)) {
            throw;
        }
        // Update fund's and user's balance and total supply of shares.
        fundBalance += investment;
        investments[msg.sender] += investment;
        if (!safecontractsTREXToken.issueTokens(msg.sender, tokenCount)) {
            // Tokens could not be issued.
            throw;
        }
        // Update stage
        if (stage == Stages.CrowdfundingGoingAndGoalNotReached) {
            if (safecontractsTREXToken.totalSupply() >= TOKEN_TARGET) {
                stage = Stages.CrowdfundingGoingAndGoalReached;
            }
        }
        // not an else clause for the edge case that the CAP and TOKEN_TARGET are reached with one big funding
        if (stage == Stages.CrowdfundingGoingAndGoalReached) {
            if (safecontractsTREXToken.totalSupply() == CAP) {
                stage = Stages.CrowdfundingEndedAndGoalReached;
            }
        }
        checkInvariants();
        return tokenCount;
    }

    // @dev Allows user to withdraw his funding if crowdfunding ended and target was not reached. Returns success.
    function withdrawFunding()
        external
        noEther
        timedTransitions
        atStage(Stages.CrowdfundingEndedAndGoalNotReached)
        returns (bool)
    {
        // Update fund's and user's balance and total supply of shares.
        uint investment = investments[msg.sender];
        investments[msg.sender] = 0;
        fundBalance -= investment;
        // Send funds back to user.
        if (investment > 0  && !msg.sender.send(investment)) {
            throw;
        }
        checkInvariants();
        return true;
    }

    // @dev Withdraws funding for trexdevshop. Returns success.
    function withdrawForTrexdevshop()
        external
        noEther
        timedTransitions
        atStage(Stages.CrowdfundingEndedAndGoalReached)
        returns (bool)
    {
        uint value = fundBalance;
        fundBalance = 0;
        if (value > 0  && !safecontractsTREXFund.trexdevshop().send(value)) {
            throw;
        }
        checkInvariants();
        return true;
    }

    // @dev Sets token value in Wei.
    // @param valueInWei New value.
    function changeBaseValue(uint valueInWei)
        external
        noEther
        onlyOwner
        returns (bool)
    {
        baseValue = valueInWei;
        return true;
    }

    // @dev Returns if 1 years passed since beginning of crowdfunding.
    function trexdevshopWaited1Years()
        constant
        external
        noEther
        returns (bool)
    {
        return now - startDate >= TOKEN_LOCKING_PERIOD;
    }

    // @dev Returns if campaign ended successfully.
    function campaignEndedSuccessfully()
        constant
        external
        noEther
        returns (bool)
    {
        if (stage == Stages.CrowdfundingEndedAndGoalReached) {
            return true;
        }
        return false;
    }

    // updateStage allows calls to receive correct stage. It can be used for transactions but is not part of the regular crowdfunding routine.
    // It is not marked as constant because timedTransitions modifier is altering state and constant is not yet enforced by solc.
    // @dev returns correct stage, even if a function with timedTransitions modifier has not yet been called successfully.
    function updateStage()
        external
        timedTransitions
        noEther
        returns (Stages)
    {
        return stage;
    }

    // @dev Setup function sets external contracts' addresses.
    // @param safecontractsTREXFundAddress Crowdfunding address.
    // @param safecontractsTREXTokenAddress Token address.
    function setup(address safecontractsTREXFundAddress, address safecontractsTREXTokenAddress)
        external
        onlyOwner
        noEther
        returns (bool)
    {
        if (address(safecontractsTREXFund) == 0 && address(safecontractsTREXToken) == 0) {
            safecontractsTREXFund = SafecontractsTREXFund(safecontractsTREXFundAddress);
            safecontractsTREXToken = SafecontractsTREX(safecontractsTREXTokenAddress);
            return true;
        }
        return false;
    }

    // @dev Contract constructor function sets owner and start date.
    function SafecontractsTREXCrowdfunding() noEther {
        // Set owner address
        owner = msg.sender;
        // Set start-date of crowdfunding
        startDate = now;
    }

    // @dev Fallback function always fails. Use fund function to fund the contract with Ether.
    function () {
        throw;
    }
}
