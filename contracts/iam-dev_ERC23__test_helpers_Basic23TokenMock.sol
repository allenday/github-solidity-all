pragma solidity ^0.4.15;

import '../../contracts/token/Basic23Token.sol';

// mock class using Basic23Token
contract Basic23TokenMock is Basic23Token {

      function Basic23TokenMock(address _initialAccount, uint256 _initialBalance) {
        balances[_initialAccount] = _initialBalance;
        totalSupply = _initialBalance;
      }

}
