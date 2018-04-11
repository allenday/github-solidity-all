pragma solidity ^0.4.13;

import "truffle/Assert.sol";

// ========= Contract for testing throwing functions ===============
// see more info http://truffleframework.com/tutorials/testing-for-throws-in-solidity-tests
contract ThrowProxy
{
	address public target;
	bytes data;

	function ThrowProxy(address _target) 
		{ target = _target;	}    

	function()  //prime the data using the fallback function.
		{ data = msg.data; }

	function execute() returns (bool) 
		{ return target.call(data); }

	function remove()
		{ selfdestruct(msg.sender); }
}