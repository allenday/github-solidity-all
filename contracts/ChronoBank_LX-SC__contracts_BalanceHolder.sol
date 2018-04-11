/**
 * Copyright 2017–2018, LaborX PTY
 * Licensed under the AGPL Version 3 license.
 */

pragma solidity ^0.4.18;


import './adapters/Roles2LibraryAdapter.sol';
import './base/ERC20Interface.sol';


contract BalanceHolder is Roles2LibraryAdapter {

    function BalanceHolder(address _roles2Library) Roles2LibraryAdapter(_roles2Library) public {

    }

    function deposit(address _from, uint _value, ERC20Interface _contract) auth external returns (bool) {
        return _contract.transferFrom(_from, this, _value);
    }

    function withdraw(address _to, uint _value, ERC20Interface _contract) auth external returns (bool) {
        return _contract.transfer(_to, _value);
    }
}
