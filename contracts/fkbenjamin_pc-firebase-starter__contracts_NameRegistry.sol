pragma solidity ^0.4.11;

import "./mortal.sol";

/// @title Name Resolver for multiple contracts
/// Resolves contract names to their current version's address
/// version 0.4
contract NameRegistry is owned, mortal {

    // Here we store the names. Make it public to automatically generate an
    // accessor function named 'contracts' that takes a fixed-length string as argument.
    mapping (bytes32 => address) public contracts;

    // Register the provided name with the caller address.
    // Also, we don't want them to register "" as their name.
    function register(bytes32 name, address contractAddress) onlyOwner() {
        if(name != ""){
            contracts[name] = contractAddress;
        }
    }

    // Unregister the provided name with the caller address.
    function unregister(bytes32 name) onlyOwner() {
        if(contracts[name] != 0 && name != ""){
            contracts[name] = 0x0;
        }
    }
}
