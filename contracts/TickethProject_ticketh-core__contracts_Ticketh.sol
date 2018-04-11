pragma solidity ^0.4.4;
import 'zeppelin-solidity/contracts/token/StandardToken.sol';

contract Ticketh is StandardToken {
  string public name = 'Ticketh';
  string public symbol = 'TKT';
  uint public decimals = 2;
  uint public INITIAL_SUPPLY = 12000;

  function Ticketh() {
    totalSupply = INITIAL_SUPPLY;
    balances[msg.sender] = INITIAL_SUPPLY;
  }
}
