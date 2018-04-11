pragma solidity ^0.4.2;

contract storenumber{
    uint number;
    function storenumber() public{
        number=100;
    }
    
    function increment() public{
    number = number +1 ;   
    }
    
    function decrement() public{
        number =number -1;
    }
    
    function fetch() public constant returns(uint) {
        return number;
    }
    
    function setnumber(uint thenewvalue) public{
        number=thenewvalue;
    }
}
