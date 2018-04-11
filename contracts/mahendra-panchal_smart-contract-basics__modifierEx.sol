pragma solidity ^0.4.4;

/** @title modifierEx 
*   fetch contract private value
*/
contract modifierEx {
    
    address private currentOwner;
    
    function modifierEx() {
        currentOwner = msg.sender;
    }
    
    function getData() isOwner returns(address) {
        return currentOwner;
    }
    
    modifier isOwner() {
        if(currentOwner == msg.sender) {
           _; 
        } else {
            throw;    
        }
    }
    
}