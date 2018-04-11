// token.sol -- ERC20 implementation with minting and burning

// Copyright (C) 2015, 2016, 2017  DappHub, LLC

// Licensed under the Apache License, Version 2.0 (the "License").
// You may not use this file except in compliance with the License.

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND (express or implied).

pragma solidity ^0.4.13;

import "./Stoppable.sol";
import "./ERC20.sol";
import "./TokenLogic.sol";

contract Token is ERC20, Stoppable {

    bytes32 public symbol;    
    string public name; // Optional token name
    uint256 public decimals = 18; // standard token precision. override to customize
    TokenLogic public logic;

    function Token(string name_, bytes32 symbol_) {
        name = name_;
        symbol = symbol_;
    }

    function setLogic(TokenLogic logic_) auth note returns(bool){
        logic = logic_;
        return true;
    }

    function setOwner(address owner_) auth {
        uint wad = balanceOf(owner);
        logic.transfer(owner, owner_, wad);
        Transfer(owner, owner_, wad);
        logic.setOwner(owner_);
        super.setOwner(owner_);
    }


    function totalSupply() constant returns (uint256){
        return logic.totalSupply();
    }

    function balanceOf( address who ) constant returns (uint value) {
        return logic.balanceOf(who);
    }

    function allowance( address owner, address spender ) constant returns (uint _allowance) {
        return logic.allowance(owner, spender);
    }

    function transfer(address dst, uint wad) stoppable note returns (bool) {
        bool retVal = logic.transfer(msg.sender, dst, wad);
        Transfer(msg.sender, dst, wad);
        return retVal;
    }
    
    function transferFrom(address src, address dst, uint wad) stoppable note returns (bool) {
        bool retVal = logic.transferFrom(src, dst, wad);
        Transfer(src, dst, wad);
        return retVal;
    }

    function approve(address guy, uint wad) stoppable note returns (bool) {
        return logic.approve(msg.sender, guy, wad);
    }

    function push(address dst, uint128 wad) returns (bool) {
        return transfer(dst, wad);
    }

    function pull(address src, uint128 wad) returns (bool) {
        return transferFrom(src, msg.sender, wad);
    }

    function mint(uint128 wad) auth stoppable note {
        logic.mint(wad);
        Transfer(this, msg.sender, wad);
    }

    function burn(uint128 wad) auth stoppable note {
        logic.burn(msg.sender, wad);
    }

    function setName(string name_) auth {
        name = name_;
    }

    function setSymbol(bytes32 symbol_) auth {
        symbol = symbol_;
    }

    function () payable {
        require(msg.value > 0);
        uint wad = logic.handlePayment(msg.sender, msg.value);
        Transfer(this, msg.sender, wad);
    }

/*special functions for ICO*/
    function transferEth(address dst, uint wad) {
        require(msg.sender == address(logic));
        require(wad < this.balance);
        dst.transfer(wad);
    }

/*this function is called from logic to trigger the correct event upon receiving ETH*/
    function triggerTansferEvent(address src,  address dst, uint wad) {
        require(msg.sender == address(logic));
        Transfer(src, dst, wad);
    }

    function payout(address dst) auth {
        require(dst != address(0));
        dst.transfer(this.balance);
    }

}
