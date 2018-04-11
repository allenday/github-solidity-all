pragma solidity ^0.4.0;

contract MockDeed {
    function MockDeed(address _owner) {
        owner = _owner;
		previousOwner = 0x0;
    }
    
    address public owner;
    address public previousOwner;
    
    function setOwner(address _owner) {
    	previousOwner = owner;
        owner = _owner;
    }
}
