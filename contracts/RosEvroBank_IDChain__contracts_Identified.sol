pragma solidity ^0.4.10;
import "Ownable.sol";
contract Identified is Ownable{
    mapping(address => mapping (address => mapping (bytes32 => bool ))) public mIdentified;
    address idChain;
    function Identified() {
    }
    
    function setIDChain (address _address) onlyOwner {
        idChain = _address;
    }
    
    function identified (address _donor, address _recipient, bytes32 _hash) {
        if (msg.sender != idChain){
            return;
        }
        mIdentified[_donor][_recipient][_hash] = true;
    }
}