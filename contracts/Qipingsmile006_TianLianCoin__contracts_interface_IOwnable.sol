pragma solidity ^0.4.11;

/**
 * 
 */
contract IOwnable {

	/* 转移拥有者，第一步，提交转移权限 */
	function transferOwnership(address newOwner) public;
	/* 转移拥有者，第二步，接收权限 */
	function acceptOwnership() public;

	event OwnershipUpdate(address indexed oldOwner, address indexed newOwner);

}

