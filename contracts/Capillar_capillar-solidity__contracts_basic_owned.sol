pragma solidity ^0.4.0;

// Basic contract for owner that can be transfered
contract owned
{
	address public owner;

	modifier onlyOwner() 
		{  require(msg.sender == owner);   _;   }

	function owned() 
		{  owner = msg.sender;  }

	function setOwner(address _newOwner) onlyOwner
	{ 
		require(owner != _newOwner);
		owner = _newOwner; 
	}
}