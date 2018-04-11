pragma solidity ^0.4.15;
import "../RocketPoolToken.sol";
import "../base/SalesAgent.sol";
import "../base/Owned.sol";
import "../lib/SafeMath.sol";



/// @title The main Rocket Pool Token (RPL) crowdsale contract
/// @author David Rugendyke - http://www.rocketpool.net

/*****************************************************************
*   This is the Rocket Pool crowdsale sale agent contract. It allows
*   deposits from the public for RPL tokens. Tokens are distributed
*   when the end date for the sale passes and uses collect their
*   tokens + any refund applicable. Tokens are distributed in a
*   proportional method that avoids the ‘rush’ associated with current
*   ICOs by allocating tokens based on the amount of ether deposited over time,
*   rather than selling to whomever gets there first.
/****************************************************************/

 // Tokens allocated proportionately to each sender according to amount of ETH contributed as a fraction of the total amount of ETH contributed by all senders.
 // credit for original distribution idea goes to hiddentao - https://github.com/hiddentao/ethereum-token-sales


contract RocketPoolCrowdsale is SalesAgent, Owned {

    /**** Libs *****************/
    
    using SafeMath for uint;

    /**** Properties ***********/

    bool public targetEthSent = false;
    bool public saleDepositsAllowed = false; 
    uint256 public deployedTime;


    /**** Methods ************ */

    // Constructor
    /// @dev Sale Agent Init
    /// @param _tokenContractAddress The main token contract address
    function RocketPoolCrowdsale(address _tokenContractAddress) {
        // Set the main token address
        tokenContractAddress = _tokenContractAddress;
        // Set the time the contract was deployed
        deployedTime = now;
    }


    // Default payable
    /// @dev Accepts ETH from a contributor, calls the parent token contract to mint tokens
    function() payable external { 
        // Get the token contract
        RocketPoolToken rocketPoolToken = RocketPoolToken(tokenContractAddress);
        // The target ether amount
        uint256 targetEth = rocketPoolToken.getSaleContractTargetEtherMin(this);
        // Only allow sales if set to true
        assert(saleDepositsAllowed == true);
        // Do some common contribution validation, will throw if an error occurs
        assert(rocketPoolToken.validateContribution(msg.value));
        // Add to contributions, automatically checks for overflow with safeMath
        contributions[msg.sender] = contributions[msg.sender].add(msg.value);
        contributedTotal = contributedTotal.add(msg.value);
        // Fire event
        Contribute(this, msg.sender, msg.value); 
        FlagUint(contributedTotal);
        // Have we met the min required ether for this sale to be a success? Send to the deposit address now
        if (contributedTotal >= targetEth && targetEthSent == false) {
            // Send to deposit address - revert all state changes if it doesn't make it
            assert(rocketPoolToken.getSaleContractDepositAddress(this).send(targetEth) == true);
            // Fire the event     
            TransferToDepositAddress(this, msg.sender, targetEth);
            // Mark as true now
            targetEthSent = true;
        }
    }

    /// @dev Allows contributors to claim their tokens and/or a refund via a public facing method
    function claimTokensAndRefund() external {
        // Get the tokens and refund now
        sendTokensAndRefund(msg.sender);
    }

    /// @dev onlyOwner - Sends a users tokens to the user after the sale has finished, included incase some users cant figure out running the claimTokensAndRefund() method themselves
    /// @param _contributerAddress Address of the crowdsale user
    function ownerClaimTokensAndRefundForUser(address _contributerAddress) external onlyOwner {
        // The owner of the contract can trigger a users tokens to be sent to them if they can't do it themselves
       sendTokensAndRefund(_contributerAddress);
    }


    /// @dev Sends the contributors their tokens and/or a refund. If funding failed then they get back all their Ether, otherwise they get back any excess Ether
    function sendTokensAndRefund(address _contributerAddress) private {
        // Get the token contract
        RocketPoolToken rocketPoolToken = RocketPoolToken(tokenContractAddress);
        // Set the target ether amount locally
        uint256 targetEth = rocketPoolToken.getSaleContractTargetEtherMin(this);
        // Must have previously contributed
        assert(contributions[_contributerAddress] > 0); 
        // Deposits must no longer be allowed
        assert(saleDepositsAllowed == false); 
        // The users contribution
        uint256 userContributionTotal = contributions[_contributerAddress];
        // Deduct the contribution now to protect against recursive calls
        contributions[_contributerAddress] = 0; 
        // Has the contributed total not been reached, but the crowdsale is over?
        if (contributedTotal < targetEth) {
            // Target wasn't met, refund the user
            assert(_contributerAddress.send(userContributionTotal) == true);
            // Fire event
            Refund(this, _contributerAddress, userContributionTotal);
        } else {
            // Max tokens alloted to this sale agent contract
            uint256 totalTokens = rocketPoolToken.getSaleContractTokensLimit(this);
            uint256 totalRefund = (contributedTotal - targetEth).mul(userContributionTotal) / contributedTotal;
            // Calculate how many tokens the user gets
            rocketPoolToken.mint(_contributerAddress, totalTokens.mul(userContributionTotal) / contributedTotal);
            // Calculate the refund this user will receive
            assert(_contributerAddress.send(totalRefund) == true);
            // Fire events
            ClaimTokens(this, _contributerAddress, rocketPoolToken.balanceOf(_contributerAddress));
            Refund(this, _contributerAddress, totalRefund);
        }
    }


    /// @dev onlyOwner - When the sale is finished the owner can flag this and allow tokens + refunds to be collected
    function setSaleDepositsAllowed(bool _set) external onlyOwner {
        saleDepositsAllowed = _set;
    }

  
    /// @dev onlyOwner - Can kill the contract and claim any ether left in it, can only do this 6 months after it has been deployed, good as a backup
    function kill() external onlyOwner {
        // Only allow access after 6 months
        assert (now >= (deployedTime + 24 weeks));
        // Now self destruct and send any dust/ether left over
        selfdestruct(msg.sender);
    }


}
