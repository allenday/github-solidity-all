pragma solidity ^0.4.18;

contract Owned {

    address owner;
    
    function Owned() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
}