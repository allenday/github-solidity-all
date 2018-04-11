pragma solidity ^0.4.2;

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {

  	/// @dev 总发行量
  	/// Default assumes totalSupply can't be over max (2^256 - 1)
  	uint256 public totalSupply;
  
  	/// @dev 获取代币余额
  	function balanceOf(address who) constant returns (uint256);
  	
  	/// @dev 向指定地址转账
  	function transfer(address to, uint256 value) returns (bool);
  	
  	event Transfer(address indexed from, address indexed to, uint256 value);
}
