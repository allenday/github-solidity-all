/**
 * Copyright 2017–2018, LaborX PTY
 * Licensed under the AGPL Version 3 license.
 */

pragma solidity ^0.4.18;


import './ERC20Interface.sol';


/**
 * @title Owned contract with safe ownership pass.
 *
 * Note: all the non constant functions return false instead of throwing in case if state change
 * didn't happen yet.
 */
contract Owned {
    address public contractOwner;
    address public pendingContractOwner;

    function Owned() public {
        contractOwner = msg.sender;
    }

    modifier onlyContractOwner {
        if (contractOwner == msg.sender) {
            _;
        }
    }

    /**
     * Prepares ownership pass.
     *
     * Can only be called by current owner.
     *
     * @param _to address of the next owner.
     *
     * @return success.
     */
    function changeContractOwnership(address _to) public onlyContractOwner returns (bool) {
        if (_to == 0x0) {
            return false;
        }
        pendingContractOwner = _to;
        return true;
    }

    /**
     * Finalize ownership pass.
     *
     * Can only be called by pending owner.
     *
     * @return success.
     */
    function claimContractOwnership() public returns (bool) {
        if (pendingContractOwner != msg.sender) {
            return false;
        }

        contractOwner = pendingContractOwner;
        delete pendingContractOwner;
        return true;
    }

    /**
    *  Withdraw given tokens from contract to owner.
    *  This method is only allowed for contact owner.
    */
    function withdrawTokens(address[] tokens) external onlyContractOwner {
        for (uint i = 0; i < tokens.length; i++) {
            ERC20Interface token = ERC20Interface(tokens[i]);
            uint balance = token.balanceOf(this);
            if (balance != 0) {
                token.transfer(msg.sender, balance);
            }
        }
    }

    /**
    *  Withdraw ether from contract to owner.
    *  This method is only allowed for contact owner.
    */
    function withdrawEther() external onlyContractOwner {
        if (this.balance > 0)  {
            msg.sender.transfer(this.balance);
        }
    }
}
