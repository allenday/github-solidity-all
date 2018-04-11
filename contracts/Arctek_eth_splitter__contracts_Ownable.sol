pragma solidity 0.4.15;

contract Ownable {
	address public owner;

	event LogSetOwner(address indexed oldOwner, address indexed newOwner);

	modifier isOwner(){
		require(msg.sender == owner);
		_;
	}

	function Ownable() public{
		owner = msg.sender;
	}

	function setOwner(address newOwner) public isOwner returns(bool success){
		require(newOwner != address(0));
		require(newOwner != owner);
		LogSetOwner(owner, newOwner);
		owner = newOwner;
		return true;
	}
}
