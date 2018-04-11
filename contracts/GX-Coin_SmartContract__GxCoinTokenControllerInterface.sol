pragma solidity ^0.4.2;

contract GxCoinTokenControllerInterface {
    function totalSupply() constant returns (uint supply);
    function balanceOf(address who) constant returns (uint amount);
    function allowance(address owner, address spender) constant returns (uint _allowance);
    function transfer(address _caller, address to, uint value) returns (bool ok);
    function transferFrom(address _caller, address from, address to, uint value) returns (bool ok);
    function approve( address _caller, address spender, uint value) returns (bool ok);
}