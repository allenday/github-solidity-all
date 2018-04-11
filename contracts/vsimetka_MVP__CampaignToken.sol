pragma solidity ^0.4.4;

import "HumanStandardToken.sol";

/// @title CampaignToken Contract
/// @author Jordi Baylina
/// @dev This token contract is a clone of ConsenSys's HumanStandardToken with
/// the approveAndCall function omitted; it is ERC 20 compliant.

contract CampaignToken is HumanStandardToken {

/// @dev The tokenController is the address that deployed the CampaignToken, for this
/// token it will be it will be the Campaign Contract

    address public tokenController;

/// @dev The onlyController modifier only allows the tokenController to call the function

    modifier onlyController { if (msg.sender != tokenController) throw; _; }

/// @notice `CampaignToken()` is the function that deploys a new
/// HumanStandardToken with the parameters of 0 initial tokens, the name
/// "CharityDAO Token" the decimal place of the smallest unit being 18, and the
/// call sign being "GIVE". It will set the tokenController to be the contract that
/// calls the function.

    function CampaignToken() HumanStandardToken(0,"CharityDAO Token",18,"GIVE") {
        tokenController = msg.sender;
    }

/// @notice `createTokens()` will create tokens if the campaign has not been
/// sealed.
/// @dev `createTokens()` is called by the campaign contract when
/// someone sends ether to that contract or calls `doPayment()`
/// @param beneficiary The address receiving the tokens
/// @param amount The amount of tokens the address is receiving
/// @return True if tokens are created

    function createTokens(address beneficiary, uint amount
    ) onlyController returns (bool success) {
        if (sealed()) throw;
        balances[beneficiary] += amount;  // Create tokens for the beneficiary
        totalSupply += amount;            // Update total supply
        Transfer(0, beneficiary, amount); // Create an Event for the creation
        return true;
    }

/// @notice `seal()` ends the Campaign by making it impossible to create more
/// tokens.
/// @dev `seal()` changes the tokenController to 0 and therefore can only be called by
/// the tokenCreator contract once
/// @return True if the Campaign is sealed

    function seal() onlyController returns (bool success)  {
        tokenController = 0;
        return true;
    }

/// @notice `sealed()` checks to see if the the Campaign has been sealed
/// @return True if the Campaign has been sealed and can't receive funds

    function sealed() constant returns (bool) {
        return tokenController == 0;
    }
}
