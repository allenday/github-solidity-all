pragma solidity ^0.4.1;

contract OverloadContract {

	function overloadedMethod(address arg1)  {
	}

	function overloadedMethod(address arg1, uint arg2)  {
	}

	function overloadedMethod(address arg1, uint arg2, string arg3)  {
	}

}
