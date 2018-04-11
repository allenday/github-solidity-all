pragma solidity ^0.4.13;


contract OwnedEvents {
    event LogSetOwner (address newOwner);
}


contract Owned is OwnedEvents {
    address public owner;

    function Owned() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function setOwner(address owner_) onlyOwner {
        owner = owner_;
        LogSetOwner(owner);
    }

}
