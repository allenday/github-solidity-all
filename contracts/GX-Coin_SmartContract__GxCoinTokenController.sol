pragma solidity ^0.4.2;

import './GxAuth.sol';
import './GxTradersInterface.sol';
import './GxCoinTotalsInterface.sol';
import './GxCoinTokenControllerInterface.sol';


contract GxCoinTokenController is GxAuth, GxCoinTokenControllerInterface
{
    GxTradersInterface public traders;
    GxCoinTotalsInterface public totals;

    function setTradersContract(address _traders) public auth() {
        traders = GxTradersInterface(_traders);
    }

    function setTotalsContract(address _totals) public auth() {
        totals = GxCoinTotalsInterface(_totals);
    }

    function totalSupply() constant returns (uint supply) {
        return uint(totals.totalCoins());
    }
    
    function balanceOf(address who) constant returns (uint amount) {
        return uint(traders.coinBalance(who));
    }

    function allowance(address owner, address spender) constant returns (uint _allowance) {
        throw;
    }

    function transfer(address _caller, address to, uint value) returns (bool ok) {
        throw;
    }

    function transferFrom(address _caller, address from, address to, uint value) returns (bool ok) {
        throw;
    }

    function approve(address _caller, address spender, uint value) returns (bool ok) {
        throw;
    }
}