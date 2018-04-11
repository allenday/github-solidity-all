pragma solidity ^0.4.15;

import "./prometh.sol";

contract prometheus {
	address[] public promeths;

	function createPrometh(address _contractAddress) public returns (address) {
		prometh newPrometh = new prometh(_contractAddress);
		promeths.push(newPrometh);
		return newPrometh;
	}
	

	function sayHi() returns (string)
	{
		return "Hello world!";
	}

	function promethCount() constant returns (uint256)
	{
		return promeths.length;
	}
}
