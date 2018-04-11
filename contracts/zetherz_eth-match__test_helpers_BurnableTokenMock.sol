pragma solidity ^0.4.15;

import 'zeppelin-solidity/contracts/token/BurnableToken.sol';

contract BurnableTokenMock is BurnableToken {

  function BurnableTokenMock(address initialAccount, uint initialBalance) {
    balances[initialAccount] = initialBalance;
    totalSupply = initialBalance;
  }

}
