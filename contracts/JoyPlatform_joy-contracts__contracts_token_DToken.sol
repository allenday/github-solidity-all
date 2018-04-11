pragma solidity ^0.4.11;

import './StandardToken.sol';

/**
 * @title DToken
 * @dev Simple ERC20 Token, where all tokens are pre-assigned to the contractor
 */

 contract DToken is StandardToken {
   string public constant name = "DToken";
   string public constant symbol = "DTN";
   uint8 public constant decimals = 4;

   // expression that compensates the decimal unit
   uint256 public constant INITIAL_SUPPLY = 210 * (10 ** uint256(decimals));

   function DToken() {
     totalSupply = INITIAL_SUPPLY;
     balances[msg.sender] = INITIAL_SUPPLY;
   }

 }
