pragma solidity ^0.4.15;

contract dummyAgent {

	uint128 public gasCost;
	uint128 public reward;
	uint256 public gasCalled;

	function dummyAgent () 
	{
		gasCost = 0;
		reward = 0;
	}

    function promethCost() constant public returns (uint128, uint128)
    {
        return (gasCost, reward);
    }
    
    function promethExecute() public
    {
    	gasCalled = msg.gas;
        return;
    }

    function setReward (uint128 _reward) 
    {
    	reward = _reward;
    }

    function setGasCost (uint128 _gasCost)
    {
    	gasCost = _gasCost;
    }
}