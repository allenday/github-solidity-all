pragma solidity ^0.4.8;

import "../base/StandardTokenWithOverflowProtection.sol";

/// @title Token contract - Token exchanging ChainX 1:1.
contract ChainXToken is StandardTokenWithOverflowProtection {

    /*
     *  Constants
     */
    // Token meta data
    string constant public name = "ChainX Token";
    string constant public symbol = "DCHAIN";
    uint8 constant public decimals = 18;

    /*
     *  Read and write functions
     */
    /// @dev Buys tokens with ChainX, exchanging them 1:1.
    function deposit()
        external
        payable
    {
        balances[msg.sender] = safeAdd(balances[msg.sender], msg.value);
        totalSupply = safeAdd(totalSupply, msg.value);
    }

    /// @dev Sells tokens in exchange for ChainX, exchanging them 1:1.
    /// @param amount Number of tokens to sell.
    function withdraw(uint amount)
        external
    {
        balances[msg.sender] = safeSub(balances[msg.sender], amount);
        totalSupply = safeSub(totalSupply, amount);
        if (!msg.sender.send(amount)) {
            // Sending failed
            throw;
        }
}
