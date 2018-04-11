pragma solidity ^0.4.10;

import 'zeppelin/contracts/token/MintableToken.sol';

contract DDJDTCoin is MintableToken {
    string public name = "DLTDOJO Dummy Token";
    string public symbol = "DDJDT";
    uint public decimals = 0;
    uint public INITIAL_SUPPLY = 21000000;
	function DDJDTCoin() {
		totalSupply = INITIAL_SUPPLY;
        balances[msg.sender] = INITIAL_SUPPLY;
	}
}
