pragma solidity ^0.4.11;

import './Cubic.sol';

contract Cube {

    address public destination;
    Cubic public cubicContract;    
    uint public unlockedAfter;
    uint public id;
    
	function Cube(address _destination, uint _unlockedAfter, Cubic _cubicContract) payable {
		destination = _destination;
		unlockedAfter = _unlockedAfter;
        cubicContract = _cubicContract;       
	}

    function() payable {
        require(msg.value == 0);
    }

    function setId(uint _id) external {
        require(msg.sender == address(cubicContract));
        id = _id; 
    }

    function deliver() external {
        assert(block.number > unlockedAfter); 
        cubicContract.forgetCube(this);
		selfdestruct(destination);		
	}
}