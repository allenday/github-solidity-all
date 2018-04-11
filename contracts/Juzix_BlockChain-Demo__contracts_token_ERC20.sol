pragma solidity ^0.4.2;

import './ERC20Basic.sol';

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {

	/// @dev 授权查看.eg: A 授予 B 100 token使用权限
  	function allowance(address owner, address spender) constant returns (uint256);
  	
  	/// @dev 代付
  	function transferFrom(address from, address to, uint256 value) returns (bool);
  	
  	// @dev 指定授权花费金额
  	function approve(address spender, uint256 value) returns (bool);
  	
  	event Approval(address indexed owner, address indexed spender, uint256 value);

}
