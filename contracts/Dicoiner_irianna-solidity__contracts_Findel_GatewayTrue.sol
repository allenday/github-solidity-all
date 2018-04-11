pragma solidity ^0.4.15;

import './Gateway.sol';

contract GatewayTrue is Gateway {
   function newProof() internal returns (bytes32) {
     return keccak256(value, timestamp);
   }
    
   function newValue() internal returns (int) {
     return 1;
  }
}