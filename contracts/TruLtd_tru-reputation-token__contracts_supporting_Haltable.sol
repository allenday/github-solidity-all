/// @title Haltable
/// @notice Abstract contract that allows children to implement an emergency stop mechanism.
/// Differs from Pausable by causing a throw when in halt mode.
/// Originally envisioned in FirstBlood ICO contract.
/// This smart contract code is Copyright 2017 TokenMarket Ltd. For more information see https://tokenmarket.net
/// Licensed under the Apache License, version 2.0: https://github.com/TokenMarketNet/ico/blob/master/LICENSE.txt
/// Updated by Tru Ltd November 2017 to comply with Solidity 0.4.18 syntax and Best Practices
/// @author TokenMarket Ltd/Updated by Ian Bray, Tru Ltd
pragma solidity 0.4.18;

import "./Ownable.sol";


contract Haltable is Ownable {

    bool public halted;

    /// @notice Event notify the halt status has changed
    /// @param status Status of whether token is halted or not
    event HaltStatus(bool status);

    /// @notice Modifier that requires the contract not to halted
    modifier stopInEmergency {
        require(!halted);
        _;
    }

    /// @notice Modifier that requires the contract to be halted
    modifier onlyInEmergency {
        require(halted);
        _;
    }

    /// @notice called by the owner on emergency, triggers stopped state
    function halt() external onlyOwner {
        halted = true;
        HaltStatus(halted);
    }

    /// @notice Called by the owner on end of emergency, returns to normal state
    function unhalt() external onlyOwner onlyInEmergency {
        halted = false;
        HaltStatus(halted);
    }
}