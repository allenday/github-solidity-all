pragma solidity ^0.4.11;

contract SimpleStorage {

    uint storedData = 0;

    event SetValue(uint value);

    function set(uint x) {
        storedData = x;
        SetValue(x);
    }

    function get() constant returns (uint) {
        return storedData;
    }
}
