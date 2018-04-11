pragma solidity ^0.4.15;

import "zeppelin-solidity/contracts/crowdsale/Crowdsale.sol";


/**
 * @title ExternalTokenCrowdsale
 * @dev Extension of Crowdsale with an externally provided token
 * with implicit ownership grant over it
 * 
 * Formal goals for this contract:
 * 1. Dynamically inject token into the crowdsale, one that we provide
 * 2. With the help of DualMintableToken be able to sell this token (applies to DMT as well)
 */
contract ExternalTokenCrowdsale is Crowdsale {
    function ExternalTokenCrowdsale(MintableToken _token) public {
        require(_token != address(0));
        // Modify underlying token variable 
        // (createTokenContract has already been called)
        token = _token;
    }

    function createTokenContract() internal returns (MintableToken) {
        return MintableToken(0x0); // Placeholder
    }
}