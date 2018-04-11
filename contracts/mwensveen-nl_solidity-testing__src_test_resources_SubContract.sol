pragma solidity ^0.4.7;
contract SubContract {
    address owner;
    address public delegate;
    uint public counter;

    function SubContract() {
        owner = msg.sender;
    }

    function bumpCounter(uint a) {
        counter += a;
    }
}