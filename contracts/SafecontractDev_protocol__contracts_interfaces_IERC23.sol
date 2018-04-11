pragma solidity ^0.4.15;

/**
    Implements the token fallback known as the ERC23 token standard.
    Please see TODO for more context. Breifly, the bytes data variable
    will be used to "callback" a specific function. 
 */
contract IERC23 {
    function transfer(address to, uint value, bytes data);
    function transferFrom(address from, address to, uint value, bytes data);
}