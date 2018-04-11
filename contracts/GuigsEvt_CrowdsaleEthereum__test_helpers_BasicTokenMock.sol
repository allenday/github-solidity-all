pragma solidity ^0.4.14;

import '../../contracts/BasicToken.sol';

contract BasicTokenMock is BasicToken {
    function assign(address _account, uint _balance) {
        balances[_account] = _balance;
    }
}
