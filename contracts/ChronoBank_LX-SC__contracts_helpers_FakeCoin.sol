/**
 * Copyright 2017–2018, LaborX PTY
 * Licensed under the AGPL Version 3 license.
 */

pragma solidity ^0.4.18;

// For testing purposes.
contract FakeCoin {

    // Owner of account approves the transfer of an amount to another account
    mapping (address => mapping (address => uint256)) allowed;
    mapping (address => uint) public balanceOf;

    uint public fee;
    bool public feeFromPayer;
    bool public approvalMode;
    bool public maintenanceMode;

    function mint(address _to, uint _value) external {
        balanceOf[_to] += _value;
    }

    function enableApproval() public {
        approvalMode = true;
    }

    function disableApproval() public {
        approvalMode = false;
    }

    function enableMaintenance() public {
        maintenanceMode = true;
    }

    function disableMaintenance() public {
        maintenanceMode = false;
    }

    function approve(address _spender, uint _amount) external returns (bool) {
        allowed[msg.sender][_spender] = _amount;
        return true;
    }

    modifier maintenance() {
        if (maintenanceMode) {
            return;
        }
        _;
    }

    modifier enoughCoins(address _spender, uint _value) {
        if (balanceOf[_spender] < (feeFromPayer ? _value + fee : _value)) {
            return;
        }
        _;
    }

    function transfer(address _to, uint _value)
    external
    maintenance()
        //enoughCoins(msg.sender, _value)
    returns (bool) {
        balanceOf[msg.sender] -= feeFromPayer ? _value + fee : _value;
        balanceOf[_to] += feeFromPayer ? _value : _value - fee;
        return true;
    }

    function transferFrom(address _from, address _to, uint _value)
    external
    maintenance()
        //enoughCoins(_from, _value)
    returns (bool) {
        if (!approvalMode) {
            balanceOf[_from] -= feeFromPayer ? _value + fee : _value;
            balanceOf[_to] += feeFromPayer ? _value : _value - fee;
            return true;
        }
        else {
            if (allowed[_from][msg.sender] >= (feeFromPayer ? _value + fee : _value)) {
                balanceOf[_from] -= feeFromPayer ? _value + fee : _value;
                allowed[_from][msg.sender] -= feeFromPayer ? _value + fee : _value;
                balanceOf[_to] += feeFromPayer ? _value : _value - fee;
                return true;
            }
        }
    }

    function setFee(uint _value) external {
        fee = _value;
    }

    function setFeeFromPayer() public {
        feeFromPayer = true;
    }
}
