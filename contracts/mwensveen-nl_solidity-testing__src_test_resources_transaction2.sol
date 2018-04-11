pragma solidity ^0.4.7;
contract Transaction2 {
    address sender;
    
    function Transaction2() {
        sender = msg.sender;
    }
    
    function getSender() returns (address) {
        return sender;
    }
    
    function() {
        
    }

   function value() constant returns(uint) {
       return this.balance;
   }
   
 }