pragma solidity ^0.4.4;

contract SuicideContract{

    address creator;
 
    function SuicideContract() public{
        creator = msg.sender;
    }
       
    function kill(){ 
        if (msg.sender == creator)
            suicide(creator);
    }
}