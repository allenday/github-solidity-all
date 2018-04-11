pragma solidity ^0.4.6;

contract Owned {
    address owner;

    modifier isOwner() { 
        if(msg.sender == owner) {
            _;
        }
    }

    function Owned() {
        owner = msg.sender;
    }
    
    function getOwner() constant returns(address){
        return owner;
    }
    
    function changeOwner(address _newOwner) isOwner{
        owner = _newOwner;
    }
}