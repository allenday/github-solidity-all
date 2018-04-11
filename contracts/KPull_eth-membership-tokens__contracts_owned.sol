pragma solidity ^0.4.18;

contract owned {

    event OwnerChanged(address indexed oldOwner, address indexed newOwner);

    address public owner;

    modifier byOwner() {
        require(msg.sender == owner);
        _;
    }

    function changeOwner(address _owner) byOwner {
        owner = _owner;
        OwnerChanged(msg.sender, _owner);
    }

}