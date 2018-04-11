pragma solidity ^0.4.8;

import 'zeppelin/token/StandardToken.sol';
import 'zeppelin/token/ERC20.sol';

// This contract is a fund that can be owned by many different people/addresses.
// Ownership is determined by how many of the "TokenOwnedFund" ERC20 tokens are held.
// Any ERC20 tokens that are owned by this contract can be withdrawn based on the percentage of TokenOwnedFund tokens owned by the withdrawing account.
contract TokenOwnedFund is StandardToken {
  
    string public name = "TokenOwnedFund"; 
    string public symbol = "TF1";
    uint public decimals = 18;
    uint public INITIAL_SUPPLY = 100000;

    mapping(ERC20 => mapping(address => uint)) public pendingWithdraws;
    
    // Create the TokenOwnedFund Token and assign all ownership to the creator
    function TokenOwnedFund() {
        totalSupply = INITIAL_SUPPLY;
        balances[msg.sender] = INITIAL_SUPPLY;
    }

    // Allow a token owner to redeem their ownership in this contract so that they can withdraw the underlying asset tokens.
    // The caller's TokenOwnedFund balance will be set to 0 and the number of underlying Asset Tokens will be calculated.
    // The caller can then "pull" out their assigned asset tokens in a separate call.
    // The caller must know all Addresses for underlying asset tokens and include them in this call.  If they do not include the full list, their ownership in the Asset Tokens will be lost.
    function Redeem(ERC20[] assetTokens) {

        // Verify the asssetToken list is valid
        if (!assetTokens || assetTokens.length == 0){
            throw;
        }

        // Verify the caller actually owns a piece of this fund
        uint redeemAmount = balances[msg.sender]; 
        if(redeemAmount == 0){
            throw;
        }

        // Save off the original supply before the contract info gets updated
        uint originalTotalSupply = totalSupply;

        // Update the total supply of tokens and zero out the sender's balance        
        totalSupply -= redeemAmount;
        balances[msg.sender] = 0;

        // Iterate over the asset tokens and calculate how much the redeemer should be credited with.
        for(uint i = 0; i < assetTokens.length; i++){

            // Get a reference to the current Asset Token
            ERC20 currentAssetToken = assetTokens[i];   

            // First get the total ownership of this underlying asset token
            uint totalAssetTokenOwnership = currentAssetToken.balanceOf(this);

            // If there is no ownership, then bail out to inform the user they did something wrong
            if(totalAssetTokenOwnership == 0) {
                throw;
            }

            // Save off the amount that the caller should be allowed to withdraw for this asset token
            uint assetTokenOwned = totalAssetTokenOwnership * redeemAmount / originalTotalSupply;
            pendingWithdraws[currentAssetToken][msg.sender] += assetTokenOwned;
        }
    }

    // Allow a withdraw of an Asset Token that was assigned through a redemption
    function withdrawAssetToken(ERC20 assetToken) {

        // Get the amount to withdraw
        uint amountToWithdraw = pendingWithdraws[assetToken][msg.sender];

        // Verify the amount to withdraw is valid
        if( amountToWithdraw == 0) {
            throw;
        }

        // Zero out the pending withdraw amount
        pendingWithdraws[assetToken][msg.sender] = 0;

        // Trigger the withdraw and bail if there is a problem
        if(!assetToken.transfer(msg.sender, amountToWithdraw)){
          throw;
        }
    }   
}