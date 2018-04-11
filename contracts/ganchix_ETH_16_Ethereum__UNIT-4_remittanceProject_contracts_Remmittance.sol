pragma solidity ^0.4.5;

import "./Killable.sol";
import "./Deadline.sol";

contract Remmittance is Killable, Deadline{

	uint fee;

	struct RemittanceStruct {
		address destination;
		uint balance;
		address owner;
	}

	mapping (bytes32 => RemittanceStruct) remmittances;
	mapping (address => uint) commissions;

	event LogCreateEvent(address main, address destination, bytes32 hashPassword, uint quantity, uint commission);
	event LogWithdrawCommissionEvent(address main, uint quantity);
	event LogWithdrawEvent(address main, uint quantity, address owner, uint commission);
	event LogRefundEvent(address main, uint quantity);

	function Remmittance(uint duration, uint _fee) Deadline(duration)
		public 
	{
		fee = _fee;
	}

	function getHashFromData(bytes32 passOne, bytes32 passTwo)
		public
		constant
		returns (bytes32 _hash)
	{
		return keccak256(passOne, passTwo);
	}

	function create(address destination, bytes32 hashPassword) 
		whenKillStatus(KilledStatus.ALIVE)
		whenPaused(false)
		whenExpired(false)
		payable
		public
		returns (bool success)
	{
		require(msg.value > 0);
		require(destination != address(0));
		require(hashPassword.length != 0);

		bytes32 hash = keccak256(destination, hashPassword);

		remmittances[hash].owner = msg.sender;
		remmittances[hash].destination = destination;
		remmittances[hash].balance += msg.value - fee;

		commissions[getOwner()] += fee;

		LogCreateEvent(msg.sender, destination, hashPassword, msg.value - fee, fee);

		return true;
	}

	function withdrawCommission() 
		public
		whenExpired(false)
		whenKillStatus(KilledStatus.ALIVE)
		whenPaused(false)
		returns (bool success)
	{
		require(commissions[msg.sender] > 0);
		uint quantity = commissions[msg.sender];
		commissions[msg.sender]=0;
		msg.sender.transfer(quantity);
		
		LogWithdrawCommissionEvent(msg.sender,quantity);
		
		return true;

	}


	function withdraw(bytes32 passOne, bytes32 passTwo) 
		whenExpired(false)
		whenKillStatus(KilledStatus.ALIVE)
		whenPaused(false)
		public
		returns (bool success)
	{

		bytes32 hash = createHash(msg.sender, passOne, passTwo);
		require(remmittances[hash].destination != address(0));
		require(remmittances[hash].balance > 0);
	
		uint quantity = remmittances[hash].balance;

		remmittances[hash].balance=0;
		remmittances[hash].destination.transfer(quantity-fee);


		commissions[remmittances[hash].owner] += fee;

		LogWithdrawEvent(remmittances[hash].destination, quantity-fee, remmittances[hash].owner, fee);
		return true;

	}

	function claimRefund(address destination, bytes32 hashPassword) 
		public
		whenExpired(true)
		whenKillStatus(KilledStatus.ALIVE)
		whenPaused(false)
		returns(bool success)
	{
		bytes32 hash = keccak256(destination, hashPassword);
		require(remmittances[hash].balance  > 0);
		require(remmittances[hash].owner == msg.sender);

		uint amount = remmittances[hash].balance;
		remmittances[hash].balance = 0;
		msg.sender.transfer(amount);

		LogRefundEvent(msg.sender, amount);	
		return true;
	}

	function getFee() 
		constant
		public
		returns(uint _fee)
	{
		return fee;
	}

	function createHash(address destination, bytes32 passOne, bytes32 passTwo)
		private
		constant
		returns (bytes32 hash)
	{
		return keccak256(destination, keccak256(passOne, passTwo));
	}

	function() public {
		revert();
	}
}