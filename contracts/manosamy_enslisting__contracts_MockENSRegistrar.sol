pragma solidity ^0.4.0;
import './MockDeed.sol';

contract MockENSRegistrar {
    mapping(bytes32 => MockDeed) deeds;
    
    function register(bytes32 labelHash) {
        if(deeds[labelHash] == address(0x0)) {
            deeds[labelHash] = new MockDeed(msg.sender);
        }
        else
            throw;
    }
    
    function entries(bytes32 labelHash) constant returns (uint, address, uint, uint, uint) {
        return (0,address(deeds[labelHash]), 0,0,0);
    }
    
    function transfer(bytes32 labelHash, address newOwner) {
        require(deeds[labelHash].owner() == msg.sender);
        deeds[labelHash].setOwner(newOwner);
    }
}


