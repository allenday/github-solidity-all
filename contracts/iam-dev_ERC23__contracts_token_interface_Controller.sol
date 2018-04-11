pragma solidity ^0.4.15;

/*
 * Copyright 2017, Jorge Izquierdo (Aragon Foundation)
 * Copyright 2017, Jordi Baylina (Giveth)
 *
 * Based on MiniMeToken.sol from https://github.com/Giveth/minime
 *
 * Changes made by IAM <DEV> (Elky Bachtiar) 
 * https://www.iamdeveloper.io
 *
 *
 * file: Controller.sol
 * location: ERC23/contracts/token/interface/
 *
 */

/// @dev The token controller contract must implement these functions
contract Controller {
    /// @notice Called when `_owner` sends ether to the MiniMe Token contract
    /// @param _owner The address that sent the ether to create tokens
    /// @return True if the ether is accepted, false if it throws
    function proxyPayment(address _owner) payable returns(bool success);

    /// @notice Notifies the controller about a token transfer allowing the
    ///  controller to react if desired
    /// @param _from The origin of the transfer
    /// @param _to The destination of the transfer
    /// @param _amount The amount of the transfer
    /// @return False if the controller does not authorize the transfer
    function onTransfer(address _from, address _to, uint _amount) returns(bool success);

    /// @notice Notifies the controller about an approval allowing the
    ///  controller to react if desired
    /// @param _owner The address that calls `approve()`
    /// @param _spender The spender in the `approve()` call
    /// @param _amount The amount in the `approve()` call
    /// @return False if the controller does not authorize the approval
    function onApprove(address _owner, address _spender, uint _amount) returns(bool success);
}