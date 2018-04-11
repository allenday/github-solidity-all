pragma solidity ^0.4.13;

/*

ICO Toolkit
========================

Base ICO.
Original Author :https://github.com/xas
Contributions : https://github.com/VinceBCD
Version : 1.0

*/

// ERC20 Interface: https://github.com/ethereum/EIPs/issues/20
contract ERC20 {
  function transfer(address _to, uint256 _value) returns (bool success);
  function balanceOf(address _owner) constant returns (uint256 balance);
}

contract BaseIco {
    address owner = msg.sender;

	modifier onlyOwner {
		require(msg.sender == owner);
		_;
	}

  function transferOwnership(address newOwner) onlyOwner {
      require(newOwner != 0x0);
      owner = newOwner;
  }
}
