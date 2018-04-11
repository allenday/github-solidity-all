pragma solidity ^0.4.15;

import './Gateway.sol';

contract GatewayInteger is Gateway {
    
   function newProof() internal returns (bytes32) {
     return keccak256(value, timestamp);
   }
    
   function newValue() internal returns (int) {
     return 42;
   }
}