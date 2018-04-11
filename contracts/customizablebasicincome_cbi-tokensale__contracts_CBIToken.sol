pragma solidity ^0.4.15;

import 'zeppelin-solidity/contracts/token/MintableToken.sol';

contract CBIToken is MintableToken {
	string public name = "CBI Token";
	string public symbol = "CBI";
	uint256 public decimals = 18;
}