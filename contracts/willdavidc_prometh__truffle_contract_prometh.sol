pragma solidity ^0.4.17;

contract agent {
    address contractAddress;
    
    function agent(address _contractAddress) public
    {
        contractAddress = _contractAddress;
    }
    
    function getStats() constant public returns (uint128, uint128)
    {
        return (0, 0);
    }
    
    function executeContract() public
    {
        return;
    }
}

contract prometh {
    
    agent public promethAgent;
    
    function prometh (address _contractAddress) public
    {
        promethAgent = agent(_contractAddress);
    }
    
    function getReward() constant public returns (uint128, uint128)
    {
        var (gasNeeded, payout) =  promethAgent.getStats();
        gasNeeded += 21000 + 5000;
        return (gasNeeded, payout);
    }
    
    function executeContract(uint128 expectedPayout, uint128 expectedGas) public
    {
        var (gasNeeded, payout) = promethAgent.getStats.gas(2000)();
        gasNeeded += 21000 + 2000;
        if (expectedPayout < this.balance || payout < expectedPayout || expectedGas < gasNeeded || msg.gas < gasNeeded)
            return; //use revert when Byzantine hits
        
        promethAgent.executeContract.gas(gasNeeded)();
        
        msg.sender.transfer(payout);
    }
    
    function getAddress() constant public returns (address) 
    {
        return this;
    }
}

contract prometheus {
	address[] public promeths;

	function createPrometh(address _contractAddress) public returns (address) {
		prometh newPrometh = new prometh(_contractAddress);
		promeths.push(newPrometh);
		return newPrometh;
	}
	
}
