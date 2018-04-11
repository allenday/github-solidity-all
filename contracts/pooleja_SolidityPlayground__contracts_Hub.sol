pragma solidity ^0.4.4;

// This Hub contract is just a holder on the blockchain that other contracs can reference to know
// what addresses other contracts on the platform are currently using.  This will allow for upgrades
// as time goes by and new versions of the contracts are rolled out.  This is the source of truth for
// the platform.
contract Hub {

    // Key/Value pairs of all the contracts on the platform
    mapping (string => address) public platformContracts;

    // Owner Key
    string constant HUB_OWNER = "HUB_OWNER";

    // Initialize the hub and set the owner to the address that created it
    function Hub(){

        // Set the HUB owner
        platformContracts[HUB_OWNER] = msg.sender;
    }

    // Update one of the platform addresses in the system
    function UpdatePlatformContract(string key, address value){
        
        // Verify the account updating the contract is the current hub owner
        if(msg.sender != platformContracts[HUB_OWNER]) {
            throw;
        }

        // Do some sanity checks on the key
        if( !key || key.length == 0) {
            throw;
        }

        // Do some sanity checks on the value
        if ( value == 0){
            throw;
        }

        // Update the contract
        UpdatePlatformContract[key] = value;
    }


}   