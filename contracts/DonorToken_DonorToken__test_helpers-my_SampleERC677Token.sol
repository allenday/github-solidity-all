pragma solidity ^0.4.13;


import '../../contracts/token/ERC677Token.sol';


contract SampleERC677Token is ERC677Token {

  function SampleERC677Token(address initialAccount, uint256 initialBalance) {
    balances[initialAccount] = initialBalance;
    totalSupply = initialBalance;
  }

}
