pragma solidity ^0.4.5;

import "./Pausable.sol";


contract Killable is Pausable{

	bool killed;
	bool doneEmergencydrawal;
    
	event LogKilledStatusEvent(address main, bool killValue);
   	event LogEmergencydrawalEvent(address main);


	function Killable() 
		public
	{
		killed = false;
		doneEmergencydrawal = false;
	}
    

	modifier isNotKilled 
	{
		require(!killed);
		_;
	}
    
	function kill(bool killValue) 
		isOwner 
		public 
	{
		require(isPaused());
		require(killValue != killed);
		require(!doneEmergencydrawal);
		killed = killValue;
		LogKilledStatusEvent(msg.sender, killValue);
	}

	function isKilled()
		public
		constant
		returns (bool isIndeed)
	{
		return killed;
	}

	function emergencyWithdrawal() 
		isOwner
		public
		returns (bool success) 
	{
		require(isKilled());
		require(!doneEmergencydrawal);
		doneEmergencydrawal=true;
		msg.sender.transfer(this.balance);
		LogEmergencydrawalEvent(msg.sender);
		return true;
	}

}