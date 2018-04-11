pragma solidity ^0.4.11;

contract Owned {
    /*
     *  Helper contract with functions for access management
     *  Based on https://github.com/ProvidentOne/contracts/blob/master/contracts/helpers/Owned.sol
     */
    address public owner;

    // Owned: contract constructor
    function Owned() {
        owner = msg.sender;
    }

    // onlyOwner: modifier to allow only the contract owner to execute a
    // modifed function
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    // transferOwnership: change the owner of the contract
    function transferOwnership(address newOwner) onlyOwner {
        owner = newOwner;
    }
}
