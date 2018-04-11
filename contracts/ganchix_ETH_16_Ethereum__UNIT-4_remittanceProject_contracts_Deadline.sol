pragma solidity ^0.4.5;


contract Deadline {
    
    uint deadline;
    
    function Deadline(uint duration) 
        public
    {
        deadline = block.number + duration;
        
    }
    
    function getDeadline()
        constant
        public
        returns (uint _deadline)
    {
        return deadline;
    }
    
    function isExpiredDeadline()
        constant
        public
        returns(bool isFinish)
    {
        return block.number >= deadline;
    }
    
    modifier whenExpired(bool value)
    {
        require(isExpiredDeadline() == value);
        _;
    }
}