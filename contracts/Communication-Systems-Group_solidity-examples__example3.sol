pragma solidity ^0.4.10;

//the very third example
contract Example3 {
    struct Account {
        string addr;
        uint amount; //default is 256bits
    }

    uint counter;
    mapping (uint => Account) accounts;
    address owner;

    function Example3(string addr) {
        accounts[counter++] = Account(addr, 42);
        owner = msg.sender;
    }

    function get(uint nr) constant returns (string) {
        return accounts[nr].addr;
    }

    function set(uint nr, string addr) returns (bool) {
        if(owner == msg.sender) {
            accounts[counter++] = Account(addr, nr);
            return true;
        } else {
            return false;
        }
    }
}