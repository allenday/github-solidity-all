pragma solidity ^0.4.11;


contract Player {
    address owner;
    mapping(address => uint) public results;
    mapping(address => uint[2]) public values;

    function Player() {
        owner = msg.sender;
    }

    function setResults(address name, uint result, uint[2] value) external {
        results[name] = result;
        values[name] = value;
    }

    function getGameResults() returns(uint, uint[2]) {
        return (results[msg.sender], values[msg.sender]);
    }

    function close() {
        selfdestruct(owner);
    }
}
