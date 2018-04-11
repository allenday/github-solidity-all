pragma solidity ^0.4.17;

import 'zeppelin-solidity/contracts/token/StandardToken.sol';

contract SpreadToken is StandardToken {

string public name = 'SpreadToken';
string public symbol = 'SPRED';
uint8 public decimals = 2;
uint public INITIAL_SUPPLY = 12000;


function SpreadToken() public {
  totalSupply = INITIAL_SUPPLY;
  balances[msg.sender] = INITIAL_SUPPLY;
}


}