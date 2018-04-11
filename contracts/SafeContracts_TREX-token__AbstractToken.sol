pragma solidity ^0.4.0;

// Title AbstractToken.sol
// Implements ERC 20 Token standard: https://github.com/ethereum/EIPs/issues/20
// Credit - https://github.com/ConsenSys/singulardtv-contracts

// @title Abstract token contract - Functions to be implemented by token contracts.
// @author Stefan George - <stefan.george@consensys.net>
// Customize @author Rocky Fikki - <rocky@fikki.net>
contract Token {
    // This is not an abstract function, because solc won't recognize generated getter functions for public variables as functions
    function totalSupply() constant returns (uint256 supply) {}
    function balanceOf(address owner) constant returns (uint256 balance);
    function transfer(address to, uint256 value) returns (bool success);
    function transferFrom(address from, address to, uint256 value) returns (bool success);
    function approve(address spender, uint256 value) returns (bool success);
    function allowance(address owner, address spender) constant returns (uint256 remaining);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
