pragma solidity ^0.4.18;

contract Timed {
    
    uint256 public startTime;           //seconds since Unix epoch time
    uint256 public endTime;             //seconds since Unix epoch time
    uint256 public avarageBlockTime;    //seconds

    // This check is an helper function for ÐApp to check the effect of the NEXT transaction, NOT simply the current state of the contract
    function isInTime() public view returns (bool inTime) {
        return block.timestamp >= (startTime - avarageBlockTime) && !isTimeExpired();
    }

    // This check is an helper function for ÐApp to check the effect of the NEXT transacion, NOT simply the current state of the contract
    function isTimeExpired() public view returns (bool timeExpired) {
        return block.timestamp + avarageBlockTime >= endTime;
    }

    modifier onlyIfInTime {
        require(block.timestamp >= startTime && block.timestamp <= endTime); _;
    }

    modifier onlyIfTimePassed {
        require(block.timestamp > endTime); _;
    }

    function Timed(uint256 _startTime, uint256 life, uint8 _avarageBlockTime) public {
        startTime = _startTime;
        endTime = _startTime + life;
        avarageBlockTime = _avarageBlockTime;
    }
}