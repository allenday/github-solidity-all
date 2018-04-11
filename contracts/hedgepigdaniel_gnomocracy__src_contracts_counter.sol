pragma solidity ^0.4.17;

contract Counter {
    uint value;

    function increment() public {
        value += 1;
    }

    function get() view public returns(uint) {
        return value;
    }
}
