pragma solidity ^0.4.15;


/**
 * @title Ownable
 * Based on the OpenZeppelin/Ownable contract
 * @dev The DelegateDualOwnable contract accepts two owners designated to have ownership permissions
 * the original creator of the contract can, by not enlisting, not own the contract.
 * The contract allows for double ownership, which allows for ownership to be transferred twice
 */
contract DelegateDualOwnable {
    address public ownerA;
    address public ownerB;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the provided
     * addresses.
     */
    function DelegateDualOwnable(address a, address b) public {
        // Require both addresses to exist (for 1 owner Ownable should be preferred)
        require(a != address(0) && b != address(0));
        ownerA = a;
        ownerB = b;
    }


    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(msg.sender == ownerA || msg.sender == ownerB);
        _;
    }


    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * For dual ownership, the transfer only applies to the half owned by sender, thus
     * making the contract behave as Ownable for each of its owners.
     * Note: onlyOwner is not the most efficient here; however it maintains the original
     * behaviour of the contract, importantly for onlyOwner being overriden.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) onlyOwner public {
        require(newOwner != address(0));
        if (msg.sender == ownerA) { // Note: if a == b, a gets given away first, then b.
            OwnershipTransferred(ownerA, newOwner);
            ownerA = newOwner;
        } else { // NB: If overriden onlyOwner allows other owners, owner B will get overriden.
            OwnershipTransferred(ownerB, newOwner);
            ownerB = newOwner;
        }
    }
}
