pragma solidity ^0.4.18;

contract TimedWithBlock {
    
    uint256 public startBlock;
    uint256 public endBlock;

    // This check is an helper function for ÐApp to check the effect of the NEXT transaction, NOT simply the current state of the contract
    function isInTime() public view returns (bool _open) {
        return block.number >= (startBlock - 1) && !isTimePassed();
    }

    // This check is an helper function for ÐApp to check the effect of the NEXT transacion, NOT simply the current state of the contract
    function isTimePassed() public view returns (bool _ended) {
        return block.number >= endBlock;
    }

    modifier onlyIfInTime {
        require(block.number >= startBlock && block.number <= endBlock); _;
    }

    modifier onlyIfTimePassed {
        require(block.number > endBlock); _;
    }
}