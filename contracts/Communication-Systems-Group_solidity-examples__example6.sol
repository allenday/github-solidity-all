pragma solidity ^0.4.10;

//the very sixth example
contract Example6 {

    mapping (address => mapping (bytes32 => uint)) stamps;

    function store(bytes32 hash) {
        stamps[msg.sender][hash] = block.timestamp;
    }

    function verify(address recipient, string data) constant returns (uint) {
        return stamps[recipient][sha3(data)];
    }
}