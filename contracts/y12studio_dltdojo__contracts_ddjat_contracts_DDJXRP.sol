pragma solidity ^0.4.10;

import 'zeppelin/contracts/token/MintableToken.sol';

// https://en.wikipedia.org/wiki/Ripple_(payment_protocol)

contract DDJXRP is MintableToken {
    string public name = "DLTDOJO XRP Token";
    string public symbol = "DDJXRP";
    uint public decimals = 6;
    uint public INITIAL_SUPPLY = 21000000e6;
	function DDJXRP() {
		totalSupply = INITIAL_SUPPLY;
        balances[msg.sender] = INITIAL_SUPPLY;
	}
}
