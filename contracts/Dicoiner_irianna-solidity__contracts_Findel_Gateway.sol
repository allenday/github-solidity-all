pragma solidity ^0.4.15;
/*
Contract that inherits from Gateway must implement two methods:
newValue(): assign new value to the value field
newProof(): assign new value to the proof field
    (e.g., sign with known pub key)
*/
contract Gateway {
    
   int value;
   uint timestamp;
   bytes32 proof;
    
   function Gateway() { 
       update(); 
   }
    
   function getValue() returns (int) { 
     return value; 
   }
   function getTimestamp() returns (uint) { 
     return timestamp; 
   }
   function getProof() returns (bytes32) { 
       return proof; 
   }
    
   function newProof() internal returns (bytes32);
   function newValue() internal returns (int);
    
   // bind updating value, timestamp, and proof to prevent inconsistency
   function update() {
     value = newValue();
     proof = newProof();
     timestamp = now;
   }
}