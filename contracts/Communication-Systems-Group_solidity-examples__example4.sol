pragma solidity ^0.4.10;

//the very fourth example
contract Example4 {

    event Message(
        string msg
    );

    struct Account {
        string addr;
        uint amount; //default is 256bits
    }

    uint counter;
    mapping (uint => Account) accounts;
    address owner;

    function Example4(string addr) {
        accounts[counter++] = Account(addr, 42);
        owner = msg.sender;
    }

    function get(uint nr) constant returns (string) {
        return accounts[nr].addr;
    }

    function set(uint nr, string addr) returns (bool) {
        if(owner == msg.sender) {
            accounts[counter++] = Account(addr, nr);
            Message("all set!");
            return true;
        } else {
            return false;
        }
    }
}