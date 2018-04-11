pragma solidity ^0.4.4;

import "./StandardToken.sol";
import "../SafeMathLib.sol";

/*
 * CrowdsaleToken
 *
 * Simple ERC20 Token example, with crowdsale token creation
 */

contract CrowdsaleToken is StandardToken {
  using SafeMathLib for uint;

  string public name = "CrowdsaleToken";
  string public symbol = "CRW";
  uint public decimals = 18;

  // 1 ether = 500 example tokens
  uint PRICE = 500;

  function () payable {
    createTokens(msg.sender);
  }

  function createTokens(address recipient) payable {
    if (msg.value == 0) throw;

    uint tokens = msg.value.times(getPrice());

    token.totalSupply = token.totalSupply.plus(tokens);
    token.balances[recipient] = token.balances[recipient].plus(tokens);
  }

  // replace this with any other price function
  function getPrice() constant returns (uint result) {
    return PRICE;
  }
}
