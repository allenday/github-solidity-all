pragma solidity ^0.4.2;

import './GxOwnedInterface.sol';
import './GxCallableByDeploymentAdmin.sol';


contract GxOwned is GxOwnedInterface, GxCallableByDeploymentAdmin {
    mapping(address => bool) owners;

    function GxOwned(address deploymentAdminsAddress) 
        GxCallableByDeploymentAdmin(deploymentAdminsAddress)
    {
        
    }

    modifier callableByOwner {
        if (isOwner(msg.sender)) {
            _;
        }
    }

    function isOwner(address accountAddress) public constant returns (bool) {
        return owners[accountAddress] == true;
    }

    function addOwner(address accountAddress) public callableByDeploymentAdmin {
        owners[accountAddress] = true;
    }

    function removeOwner(address accountAddress) public callableByDeploymentAdmin {
        delete owners[accountAddress];
    }
}