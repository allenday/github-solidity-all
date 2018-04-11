pragma solidity ^0.4.13;


/**
 * Describes a contract that is ownable by multiple parties.
 */
contract MultiOwnable {
    mapping (address => bool) owners;

    function MultiOwnable() {
        // Add the sender of the contract as the initial owner
        owners[msg.sender] = true;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owners[msg.sender]);
        _;
    }

    /**
     * @dev Adds an owner
     */
    function addOwner(address newOwner) onlyOwner {
        // #0 is an invalid address
        require(newOwner != address(0));

        owners[newOwner] = true;
    }

    /**
     * @dev Removes an owner
     */
    function removeOwner(address ownerToRemove) onlyOwner {
        owners[ownerToRemove] = false;
    }

    /**
     * @dev Checks if address is an owner
     */
    function isOwner(address possibleOwner) onlyOwner returns (bool) {
        return owners[possibleOwner];
    }
}
