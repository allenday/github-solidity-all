pragma solidity ^0.4.10;

//the very seventh example
contract Example7 {

    address owner;
    mapping (address => uint) accounts;

    function Example7() {
        owner = msg.sender;
    }

    function mint(address recipient, uint value) {
        if(msg.sender == owner) {
            accounts[recipient] += value;
        }
    }

    function transfer(address to, uint value) {
        if(accounts[msg.sender] >= value) {
            accounts[msg.sender] -= value;
            accounts[to] += value;
        }
    }

    function balance(address addr) constant returns (uint) {
        return accounts[addr];
    }
}