pragma solidity ^0.4.11;

contract MyKillerContract {
    address owner;
    
    function MyKillerContract() {
        owner = msg.sender;
    }
    
    function getCreator() constant returns(address) {
        return owner;
    }
    
    function kill() {
        if(msg.sender == owner) {
            selfdestruct(msg.sender);
        }
    }
}