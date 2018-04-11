pragma solidity ^0.4.2;

import './ERC20.sol';
import './GxAuth.sol';
import './GxCoinTokenControllerInterface.sol';


contract GxCoinToken is ERC20, GxAuth {
    GxCoinTokenControllerInterface public controller;

    function setControllerContract(GxCoinTokenControllerInterface _controller) auth()
    {
        controller = _controller;
    }

    function emitTransfer(address from, address to, uint amount) auth()
    {
        Transfer(from, to, amount);
    }
    
    function emitApproval(address holder, address spender, uint amount) auth()
    {
        Approval(holder, spender, amount);
    }
    
    function totalSupply() constant returns (uint supply) {
        return controller.totalSupply();
    }
    
    function balanceOf(address who) constant returns (uint value) {
        return controller.balanceOf(who);
    }
    
    function allowance(address owner, address spender) constant returns (uint _allowance) {
        return controller.allowance(owner, spender);
    }
    
    function transfer(address to, uint value) returns (bool ok) {
        return controller.transfer(msg.sender, to, value);
    }
    
    function transferFrom(address from, address to, uint value) returns (bool ok) {
        return controller.transferFrom(msg.sender, from, to, value);
    }
    
    function approve(address spender, uint value) returns (bool ok) {
        return controller.approve(msg.sender, spender, value);
    }
}