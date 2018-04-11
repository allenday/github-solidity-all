pragma solidity ^0.4.13;


import '../../contracts/token/ERC23Token.sol';


contract SampleERC23Token is ERC23Token {

  function SampleERC23Token(address initialAccount, uint256 initialBalance) {
    balances[initialAccount] = initialBalance;
    totalSupply = initialBalance;
  }

}
