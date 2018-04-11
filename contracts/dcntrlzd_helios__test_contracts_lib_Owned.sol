pragma solidity ^0.4.8;

contract Owned {
    mapping (address => bool) public owners;

    function Owned() public {
        owners[msg.sender] = true;
    }

    modifier onlyOwner {
        if (owners[msg.sender] != true) revert();
        _;
    }

    function addOwner(address ownerToAdd) public onlyOwner {
        owners[ownerToAdd] = true;
    }

    function removeOwner(address ownerToRemove) public onlyOwner {
        owners[ownerToRemove] = false;
    }
}
