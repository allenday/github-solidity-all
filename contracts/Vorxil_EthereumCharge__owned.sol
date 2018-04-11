pragma solidity ^0.4.11;


contract Owned {
	address owner;
	
	function Owned() {
		owner = msg.sender;
	}
	
	modifier onlyOwner() {
		if (msg.sender == owner) _;
	}
	
	function kill() onlyOwner {
		suicide(owner);
	}
}