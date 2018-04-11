pragma solidity ^0.4.0

contract Testimony {
    uint tid;

    mapping (uint => bytes32) public lookup;
    mapping (bytes32 => bool) public isValid;

    event savedTestimony(address from, uint testimonyID, bytes32 hash);

    function Testimony() {
        tid = 0;
    }

    function create(bytes32 hash) {
        lookup[tid] = hash;
        isValid[hash] = true;
        savedTestimony(msg.sender, tid, hash);
        tid++;
    }

    function update(uint testimonyID, bytes32 hash) {
        isValid[lookup[testimonyID]] = false;
        lookup[testimonyID] = hash;
        isValid[hash] = true;
        savedTestimony(msg.sender, testimonyID, hash);
    }
}
