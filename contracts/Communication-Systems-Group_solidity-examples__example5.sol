pragma solidity ^0.4.10;

//the very fifth example
contract Example5 {

    event Message(
        string msg
    );

    mapping (address => uint) accounts;

    function deposit() payable {
        accounts[msg.sender] += msg.value;
        Message("deposit!");
    }

    function withdraw(uint amount) returns (bool){
        if(accounts[msg.sender] >= amount) {
            accounts[msg.sender]-= amount;
            if(msg.sender.send(amount)) {
                Message("withdraw!");
                return true;
            }
        }
        Message("no withdraw!");
        return false;
    }
}