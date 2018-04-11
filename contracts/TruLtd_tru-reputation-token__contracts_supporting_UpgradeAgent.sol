/// @title UpgradeAgent
/// @notice Upgrade agent interface inspired by Lunyr that transfers tokens to a new contract.
/// Upgrade agent itself can be the token contract, or just a middle man contract doing the heavy lifting.
/// This smart contract code is Copyright 2017 TokenMarket Ltd. For more information see https://tokenmarket.net
/// Licensed under the Apache License, version 2.0: https://github.com/TokenMarketNet/ico/blob/master/LICENSE.txt
/// Updated by Tru Ltd November 2017 to comply with Solidity 0.4.18 syntax and Best Practices
/// @author TokenMarket Ltd/Updated by Ian Bray, Tru Ltd
pragma solidity ^0.4.18;


contract UpgradeAgent {
    
    uint public originalSupply;

    /// @notice Function interface to check if it is an upgradeAgent
    function isUpgradeAgent() public pure returns (bool) {
        return true;
    }

    /// @notice Function interface for upgrading a token from an address
    /// @param _from Origin address of tokens to upgrade
    /// @param _value Number of tokens to upgrade
    function upgradeFrom(address _from, uint256 _value) public;
}
