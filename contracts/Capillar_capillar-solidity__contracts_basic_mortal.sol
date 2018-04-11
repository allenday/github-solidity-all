pragma solidity ^0.4.0;

import "./owned.sol";

// Basic contract for removable contracts
contract mortal is owned
{
	function remove() onlyOwner
		{ selfdestruct(owner); }
}