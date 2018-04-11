pragma solidity ^0.4.5;

import "./Owned.sol";

contract Pausable is Owned{

	bool paused;
    
	event LogPauseEvent(address main, bool pauseValue);

	function Pausable() 
		public
	{
		paused = false;
	}
    
    
	modifier whenPaused(bool pausedValue) 
	{
		require(paused == pausedValue);
 		_;
	}

	function setPause(bool pauseValue) 
		isOwner 
		public 
	{
		require(paused != pauseValue);
		paused = pauseValue;
		LogPauseEvent(msg.sender, pauseValue);
	}
	
	function isPaused() 
		public
		constant
		returns (bool isInNeed)
	{
        return paused;
	}

}