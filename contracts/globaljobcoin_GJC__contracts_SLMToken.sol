pragma solidity ^0.4.15;

import './token/PausableToken.sol';

contract SLMToken is PausableToken {
  string constant public name = "SLM";
  string constant public symbol = "SLM";
  uint256 constant public decimals = 18;
  uint256 constant TOKEN_UNIT = 10 ** uint256(decimals);
  uint256 constant INITIAL_SUPPLY = 100000000 * TOKEN_UNIT;

  function SLMToken() {
    // Set untransferable by default to the token
    paused = true;
    // asign all tokens to the contract creator
    totalSupply = INITIAL_SUPPLY;
    Transfer(0x0, msg.sender, INITIAL_SUPPLY);
    balances[msg.sender] = INITIAL_SUPPLY;
  }
}
