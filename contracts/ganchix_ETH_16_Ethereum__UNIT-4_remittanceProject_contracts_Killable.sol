pragma solidity ^0.4.5;

import "./Pausable.sol";


contract Killable is Pausable{

    enum KilledStatus { ALIVE, KILLED, WITHDRAWN }

    KilledStatus status;
	event LogKilledStatusEvent(address main, KilledStatus killStatus);
   	event LogEmergencydrawalEvent(address main);

	function Killable() 
		public
	{
        status =  KilledStatus.ALIVE;
	}
    
    
    modifier whenKillStatus(KilledStatus killedStatus)
    {
        require(status == killedStatus);
        _;
    }
    

    modifier whenNotKillStatus(KilledStatus killedStatus)
    {
        require(status != killedStatus);
        _;
    }
    
	function getKilled()
	    public
	    constant
	    returns (KilledStatus killedStatus)
    {
        return status;
    }

	function kill(KilledStatus killValue) 
		isOwner 
		whenNotKillStatus(KilledStatus.WITHDRAWN)
		whenPaused(true)
		public 
	{
	    require(KilledStatus.WITHDRAWN != killValue);
	    require(status != killValue);

        status = killValue;
        
		LogKilledStatusEvent(msg.sender, status);
	}

	function emergencyWithdrawal() 
		isOwner
		whenKillStatus(KilledStatus.KILLED)
		whenNotKillStatus(KilledStatus.WITHDRAWN)
		public
		returns (bool success) 
	{
		status = KilledStatus.WITHDRAWN;
		msg.sender.transfer(this.balance);
		LogEmergencydrawalEvent(msg.sender);
		return true;
	}

}