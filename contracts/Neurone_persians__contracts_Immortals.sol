pragma solidity ^0.4.18;

import "./ImmortalToken.sol";

contract Immortals is ImmortalToken {

    uint256 public tokenAssigned = 0;

    event Assigned(address _contributor, uint256 _immortals);

    function () payable external {
		//Assign immortals based on ethers sent
        require(tokenAssigned < totalSupply && msg.value >= 0.5 ether);
		uint256 immortals = msg.value / 0.5 ether;
		uint256 remainder = 0;
		//Find the remainder
		if (safeAdd(tokenAssigned, immortals) > totalSupply) {
			immortals = totalSupply - tokenAssigned;
			remainder = msg.value - (immortals * 0.5 ether);
		} else {
			remainder = (msg.value % 0.5 ether);
		}	
		require(safeAdd(tokenAssigned, immortals) <= totalSupply);
		balances[msg.sender] = safeAdd(balances[msg.sender], immortals);
		tokenAssigned = safeAdd(tokenAssigned, immortals);
		assert(balances[msg.sender] <= totalSupply);
		//Send remainder to sender
		msg.sender.transfer(remainder);
		Assigned(msg.sender, immortals);
    }

	function redeemEther(uint256 _amount) onlyOwner external {
        owner.transfer(_amount);
    }
}
