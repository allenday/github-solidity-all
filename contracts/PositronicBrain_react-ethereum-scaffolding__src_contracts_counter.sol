pragma solidity ^0.4.10;

contract Counter {
    uint public counter;

    event CounterUpdated(
        uint value
    );

    function setCounter(uint value) {
        counter = value;
        CounterUpdated(value);
    }
}
