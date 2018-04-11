pragma solidity ^0.4.2;

contract GxAuthority {
    function canCall(address caller, address callee, bytes4 sig) constant returns (bool);
}