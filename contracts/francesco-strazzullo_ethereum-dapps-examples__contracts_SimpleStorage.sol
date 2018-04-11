pragma solidity ^0.4.0;

contract SimpleStorage {
    uint storedData;
    event ValueSet(uint newValue);

    function set(uint x) {
        storedData = x;
        ValueSet(x);
    }

    function get() constant returns (uint) {
        return storedData;
    }
}