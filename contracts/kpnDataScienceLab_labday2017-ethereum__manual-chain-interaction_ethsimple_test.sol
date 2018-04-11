pragma solidity ^0.4.17;

contract test { 
    uint call_count; 
    function multiply(uint a) public returns(uint d) { 
        call_count = call_count + 1;
        return a * 7; 
    } 
    function getCallCount() public view returns(uint)  {
        return call_count;
    }
}

