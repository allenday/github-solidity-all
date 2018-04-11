pragma solidity ^0.4.0;

contract SimpleStorage {
    uint storedData;

    function SimpleStorage(uint initial) {
      storedData = initial;
    }

    function set(uint x) {
        storedData = x;
    }

    function get() constant returns (uint) {
        return storedData;
    }
}
