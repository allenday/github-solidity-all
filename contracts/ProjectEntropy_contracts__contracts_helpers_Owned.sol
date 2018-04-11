pragma solidity ^0.4.4;


/**
 * Owned contracts record their creator when they come into existance
 * and provide protections so that only that creator, or one who ownership is
 * transfered to can call functions which include the onlyOwner modifier.
 */
contract Owned {
    address public owner;

    function owned() {
        owner = msg.sender;
    }

    modifier onlyOwner {
        if (msg.sender != owner) { throw; }
        else
          _;
    }

    function transferOwnership(address newOwner) onlyOwner {
        owner = newOwner;
    }
}
