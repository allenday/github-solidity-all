pragma solidity ^0.4.10;

import 'zeppelin/contracts/token/MintableToken.sol';

contract DDJBTC is MintableToken {
    string public name = "DLTDOJO BTC Token";
    string public symbol = "DDJBTC";
    uint public decimals = 8;
    uint public INITIAL_SUPPLY = 21000000e8;
	function DDJBTC() {
		totalSupply = INITIAL_SUPPLY;
        balances[msg.sender] = INITIAL_SUPPLY;
	}
}
