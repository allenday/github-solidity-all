pragma solidity ^0.4.15;

import '../../contracts/StandardToken.sol';

contract StandardTokenMock is StandardToken {

   function StandardTokenMock(address initialAccount, uint256 initialBalance) {
      balances[initialAccount] = initialBalance;
      totalSupply = initialBalance;
   }

   function assign(address _account, uint _balance) {
      balances[_account] = _balance;
   }   
}
