pragma solidity ^0.4.13;

import './token/MintableToken.sol';

contract FiatBase is MintableToken {

  /* Public variables of the token */
  string public standard = 'Fiatcoin 0.1';
  string public name;
  string public symbol;
  uint8 public decimals;
}
