pragma solidity ^0.4.10;

import 'zeppelin/contracts/token/MintableToken.sol';

contract DDJATCoin is MintableToken {
    string public name = "DLTDOJO Alice Token";
    string public symbol = "DDJAT";
    uint public decimals = 0;
    uint public INITIAL_SUPPLY = 21000000;
	function DDJATCoin() {
		totalSupply = INITIAL_SUPPLY;
        balances[msg.sender] = INITIAL_SUPPLY;
	}
}
