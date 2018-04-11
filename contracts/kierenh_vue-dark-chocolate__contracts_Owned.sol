pragma solidity ^0.4.2;

//
// Defines an owned contract.
//
contract Owned {

    // The contract owner (who has permission to destroy this contract)
    address internal owner;

    // Constructor
    function Owned() {
        owner = msg.sender;
    }

    function remove() onlyOwner {
        selfdestruct(owner);
    }

    modifier onlyOwner() {
        if (msg.sender == owner)
        _;
    }

    //
    // A restricted modifier that restricts access to the owner of this contract -OR- that the sender is the given address.
    //
    modifier restricted(address entityOwner) {       
		require (msg.sender == owner || msg.sender == entityOwner);
        _;
	}

    function transferOwnership(address newOwner) onlyOwner {
        if (newOwner != address(0)) owner = newOwner;
    }
}
