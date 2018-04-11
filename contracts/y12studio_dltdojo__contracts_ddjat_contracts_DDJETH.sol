pragma solidity ^0.4.10;

import 'zeppelin/contracts/token/MintableToken.sol';

contract DDJETH is MintableToken {
    string public name = "DLTDOJO ETH Token";
    string public symbol = "DDJETH";
    uint public decimals = 18;
    uint public INITIAL_SUPPLY = 21000000e18;
	function DDJETH() {
		totalSupply = INITIAL_SUPPLY;
        balances[msg.sender] = INITIAL_SUPPLY;
	}
}
