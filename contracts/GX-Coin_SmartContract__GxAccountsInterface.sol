pragma solidity ^0.4.2;

contract GxAccountsInterface {
    function contains(address lookupAddress) public constant returns (bool);
    function add(address newAddress) public;
    function remove(address removedAddress) public;

    function iterateStart() public constant returns (uint);
    function iterateValid(uint keyIndex) public constant returns (bool);
    function iterateNext(uint keyIndex) public constant returns (uint);
    function iterateGet(uint keyIndex) public constant returns (address);
}