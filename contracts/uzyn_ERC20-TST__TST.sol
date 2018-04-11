pragma solidity ^0.4.0;

import 'StandardToken.sol';

contract TST is StandardToken {
    string public name = 'Test Standard Token';
    string public symbol = 'TST';
    uint public decimals = 18;

    function showMeTheMoney(address _to, uint256 _value) {
        totalSupply += _value;
        balances[_to] += _value;
        Transfer(0, _to, _value);
    }
}
