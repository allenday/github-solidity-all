pragma solidity ^0.4.0;
contract testingContracts1 {

    address creator;
    uint8 arraylength = 10;
    uint8[10] integers; 
    int8 setarraysuccessful = -1; 

    function testingContracts() public
    {
        creator = msg.sender;
        uint8 x = 0;
        while(x < integers.length)
        {
        	integers[x] = 1; 
        	x++;
        }
    }
    
    function setArray(uint8[10] incoming) public  
    {
    	setarraysuccessful = 0;
    	uint8 x = 0;
        while(x < arraylength)
        {
        	integers[x] = incoming[x]; 
        	x++;
        }
        setarraysuccessful = 1;
    	return;
    }
    
    function getArraySettingResult() public constant returns (int8)
    {
    	return setarraysuccessful;
    }
    
    function getArray() public constant returns (uint8[10])  
    {
    	return integers;
    }
    
    function getValue(uint8 x) public constant returns (uint8)
    {
    	return integers[x];
    }
    
    function kill() public
    { 
        if (msg.sender == creator)
        {
            suicide(creator);  
        }
    }
}
