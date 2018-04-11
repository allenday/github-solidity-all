pragma solidity ^0.4.18;

import "./MiniMeToken.sol";

/**
 * @title iMaliToken
 * @dev the iMali token implementation with parameters
 */
contract iMaliToken is MiniMeToken {


    /* constructor - must supply a MiniMeTokenFactory address */
    function iMaliToken (address _tokenFactory) 
    public MiniMeToken(_tokenFactory, // factory address
                        address(0x0), // no parent token
                        0,            // no parent token snapshot block
                        "iMali",      // the glorious token name
                        18,           // eighteen decimals 
                        "IMALI",      // token symbol
                        true)         // transfers enabled 
    {
        // setting the version 
        version = "IML_v0.3";
    }
}