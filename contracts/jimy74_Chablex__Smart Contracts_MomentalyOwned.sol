pragma solidity ^0.4.11;

/*
    Initially from :  https://github.com/OpenZeppelin
    Changed by : Paris Jimmy

    I changed this code for my needs and decided to rename it "MomentalyOwned"

    In this version the owner can be allowed to keep somes rights,
    but he will still lose some special rights after a period of time (called here the "Q1 period").

*/

import './StandardToken.sol';

contract MomentalyOwned is StandardToken {

	event TransferOwnership(address indexed newOwner);

    address public owner;

    uint public creationTime; //Not a constant because "now" should not be initialize in compile-time

    uint public constant periodQ1 = 90 days;

    function MomentalyOwned() {
        owner = msg.sender;
        creationTime = now;
    }

    modifier onlyOwner {
		require(msg.sender == owner);
        _;
    }

	modifier onlyInQ1 {
		require(now <= creationTime.add(periodQ1));
        _;
	}

	modifier onlyAfterQ1 {
		require(now > creationTime.add(periodQ1));
        _;
	}

    function transferOwnership(address newOwner) onlyOwner {
	    require(newOwner != address(0));
      owner = newOwner;
		  TransferOwnership(newOwner);
    }

    function getTimeLeftInQ1() constant returns (uint256){
      uint256 timePicture = now;
      uint256 endOfQ1 = creationTime.add(periodQ1);
      return timePicture >= endOfQ1 ? 0 : endOfQ1.sub(timePicture);
    }
}
