pragma solidity ^0.4.11;
import "../RocketPoolToken.sol";
import "../base/SalesAgent.sol";


/// @title The main Rocket Pool Token (RPL) reserve fund contract, reserved tokens for future dev work, code/bug bounties, audits, security and more
/// @author David Rugendyke - http://www.rocketpool.net


/*****************************************************************
*   This is the Rocket Pool reserve fund sale agent contract. It mints
*   tokens from the main erc20 token instantly when claimReserveTokens
*   is called. Tokens are assigned to the depositAddress for this
*   sale agent. 15% of all tokens are reserved for RP future work.
/****************************************************************/


contract RocketPoolReserveFund is SalesAgent {

    // Constructor
    /// @dev Sale Agent Init
    /// @param _tokenContractAddress The main token contract address
    function RocketPoolReserveFund(address _tokenContractAddress) {
        // Set the main token address
        tokenContractAddress = _tokenContractAddress;
    }

    /// @dev Allows RP to collect the reserved tokens
    function claimReserveTokens() external {
        // Get our main token contract
        RocketPoolToken rocketPoolToken = RocketPoolToken(tokenContractAddress);
        // The max tokens assigned to this sale agent contract is our reserve fund, mint these to our deposit address for this agent
        // Will throw if minting conditions are not met, ie depositAddressCheckedIn is false, sale has been finalised
        rocketPoolToken.mint(
            rocketPoolToken.getSaleContractDepositAddress(this),
            rocketPoolToken.getSaleContractTokensLimit(this)
        );
        // Finalise this sale, will verify the senders address, contribution amount and more - 
        // Throws if basic finalisation settings are not met and msg.sender must be the depositAddress asigned for the sale agent
        rocketPoolToken.setSaleContractFinalised(msg.sender);  
        // Fire the event
        ClaimTokens(this, msg.sender, rocketPoolToken.balanceOf(msg.sender));
    }

    
}
