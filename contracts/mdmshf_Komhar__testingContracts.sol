pragma solidity ^0.4.2;

contract testingContracts{
    uint Value;
    function testingContracts() public{
        Value=8545;
    }
    
    function incrementValue() public{
    Value = Value +1 ;   
    }
    
    function decrementValue() public{
        Value =Value -1;
    }
    
    function fetchValue() public constant returns(uint) {
        return Value;
    }
    
    function setValue(uint newvalue) public{
        Value=newvalue;
    }
}
