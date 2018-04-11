pragma solidity ^0.4.5;

contract Owned{

	address owner;

	event LogOwnerChangeEvent(address oldOwner, address newOwner);

	function Owned() 
		public
	{
		owner = msg.sender;
	}
    
	modifier isOwner 
	{
		require(msg.sender == owner);
		_;
	}

	function getOwner()
		constant 
		public 
		returns(address _owner)
	{
		return owner;
	}

	function setOwner(address newOwner)
		isOwner
		public
		returns (bool success)
	{
		require(newOwner != address(0));
		require(newOwner != owner);
		owner = newOwner;
		LogOwnerChangeEvent(msg.sender, newOwner);
		return true;

	}

}