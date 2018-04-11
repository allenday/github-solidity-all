pragma solidity ^0.4.11;

import "../contracts/Owned.sol";

contract ThrowProxy {
	
	address public target;
	bytes data;
	
	function ThrowProxy(address _target) {
		target = _target;
	}
	
	function transferOwnership(Owned owned, address new_owner) {
		owned.transferOwnership(new_owner);
	}
	
	function execute() returns (bool) {
		return target.call(data);
	}
	
	function() {
		data = msg.data;
	}
	
}