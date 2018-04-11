pragma solidity ^0.4.7;
contract Transaction1 {
    address sender;
    
    function Transaction1() {
        sender = msg.sender;
    }

    function getSender() returns (address) {
        return sender;
    }
    
    function() payable {
        
    }

   function value() constant returns(uint) {
       return this.balance;
   }
   
 }