pragma solidity ^0.4.4;

contract Constructor{

    address creator;
    string greeting;

    function Constructor(string _greeting) public{
        creator = msg.sender;
        greeting = _greeting;
    }

    function greet() constant returns (string){
        return greeting;
    }
    
    function getBlockNumber() constant returns (uint){
        return block.number;
    }
    
    function setGreeting(string _newgreeting){
        greeting = _newgreeting;
    }
        
    function kill(){ 
        if (msg.sender == creator)
            suicide(creator);
    }
}