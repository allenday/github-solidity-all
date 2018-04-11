pragma solidity ^0.4.15;

/*
 *  Copyright 2017, Jorge Izquierdo (Aragon Foundation)
 * Copyright 2017, Jordi Baylina (Giveth)
 *
 * Based on MiniMeToken.sol from https://github.com/Giveth/minime
 *
 * Changes made by IAM <DEV> (Elky Bachtiar) 
 * https://www.iamdeveloper.io
 *
 *
 * file: Controlled.sol
 * location: ERC23/contracts/token/interface/
 *
 */

contract Controlled {

    function Controlled() { controller = msg.sender;}

    /// @notice The address of the controller is the only address that can call
    ///  a function with this modifier
    modifier onlyController { 
        require(msg.sender == controller);
        _; 
    }

    address public controller;
    
    /// @notice Changes the controller of the contract
    /// @param _newController The new controller of the contract
    function changeController(address _newController) onlyController {
        controller = _newController;
    }
}