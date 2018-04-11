pragma solidity ^0.4.15;

import '../../contracts/token/Standard23Token.sol';

// mock class using Standard23Token
contract Standard23TokenMock is Standard23Token {

      function Standard23TokenMock(address _initialAccount, uint256 _initialBalance) {
        balances[_initialAccount] = _initialBalance;
        totalSupply = _initialBalance;
      }
      
}
