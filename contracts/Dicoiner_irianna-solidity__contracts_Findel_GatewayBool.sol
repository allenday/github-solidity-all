pragma solidity ^0.4.15;

import './Gateway.sol';

contract GatewayBool is Gateway {
    
   function newBooleanValue() internal returns (bool) {
      return (block.timestamp % 2 == 0);
   }
    
   function newProof() internal returns (bytes32) {
      return keccak256(value, timestamp);  // let's pretend it proves something
   }
    
   function newValue() internal returns (int) {
      if (newBooleanValue())
         return(1);
      else return(0);
   }
    
}