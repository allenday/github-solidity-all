contract ChainInfo {

    address creator;
    function ChainInfo()
    {
        creator = msg.sender; 								    
    }
	 
	function getContractAddress() constant returns (address) 
	{
		return this;
	}
    
    function getContractBalance() constant returns (uint) 
    {
    	return this.balance;
    }
    
	function getCurrentMiner() constant returns (address) 
	{
		return block.coinbase;
	}
	
	function getCurrentDifficulty() constant returns (uint)
	{
		return block.difficulty;
	}
	
	function getCurrentGaslimit() constant returns (uint)
	{													  
		return block.gaslimit;
	}
	
	function getCurrentBlockNumber() constant returns (uint)
	{
		return block.number;
	}
    
    function getBlockTimestamp() constant returns (uint)
    {													
    	return block.timestamp;
    }
    
    function getMessageData() constant returns (bytes)
    {
    	return msg.data;
    }
    
    function getMessageSender() constant returns (address)
    {
    	return msg.sender;
    }
    
    function getMessageValue() constant returns (uint)
    {
    	return msg.value;
    }
    
    function getMessageGas() constant returns (uint)        
    {													
    	return msg.gas;
    }
    
	function getTxGasprice() constant returns (uint)
    {											     	
    	return tx.gasprice;
    }
    
    function getTxOrigin() constant returns (address)
    {
    	return tx.origin;
    }
    
    function kill()
    { 
        if (msg.sender == creator)
            suicide(creator);
    }
}