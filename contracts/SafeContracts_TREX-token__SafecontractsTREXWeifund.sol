pragma solidity ^0.4.0;

// Title SafecontractsTREXWeifund.sol

import "AbstractCampaign.sol";
import "AbstractSafecontractsTREXFund.sol";
import "AbstractSafecontractsTREXCrowdfunding.sol";


// @title Crowdfunding contract - Implements crowdfunding functionality.
// @author Stefan George - <stefan.george@consensys.net>
// Customize @author Rocky Fikki - <rocky@fikki.net>
// Credit - https://github.com/ConsenSys/singulardtv-contracts

contract SafecontractsTREXWeifund is Campaign {

    /*
     *  External contracts
     */
    SafecontractsTREXFund constant safecontractsTREXFund = SafecontractsTREXFund({{SafecontractsTREXFund}});
    SafecontractsTREXCrowdfunding constant safecontractsTREXCrowdfunding = SafecontractsTREXCrowdfunding({{SafecontractsTREXCrowdfunding}});

    string constant public name = "SafecontractsTREX Campaign";
    string constant public contributeMethodABI = "fund()";
    string constant public refundMethodABI = "withdrawFunding()";
    string constant public payoutMethodABI = "withdrawForTrexdevshop()";

    // @notice use to determine the beneficiary destination for the campaign
    // @return the beneficiary address that will receive the campaign payout
    function beneficiary() constant returns(address) {
        return safecontractsTREXFund.trexdevshop();
    }

    // @notice the time at which the campaign fails or succeeds
    // @return the uint unix timestamp at which time the campaign expires
    function expiry() constant returns(uint256 timestamp) {
        return safecontractsTREXCrowdfunding.startDate() + safecontractsTREXCrowdfunding.CROWDFUNDING_PERIOD();
    }

    // @notice the goal the campaign must reach in order for it to succeed
    // @return the campaign funding goal specified in wei as a uint256
    function fundingGoal() constant returns(uint256 amount) {
        return safecontractsTREXCrowdfunding.TOKEN_TARGET() * safecontractsTREXCrowdfunding.valuePerShare();
    }

    // @notice the goal the campaign must reach in order for it to succeed
    // @return the campaign funding goal specified in wei as a uint256
    function amountRaised() constant returns(uint256 amount) {
        return safecontractsTREXCrowdfunding.fundBalance();
    }
}
