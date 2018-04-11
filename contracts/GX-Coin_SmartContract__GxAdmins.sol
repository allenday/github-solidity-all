pragma solidity ^0.4.2;

import './GxCallableByDeploymentAdmin.sol';
import './GxEditable.sol';
import './GxAccounts.sol';

contract GxAdminsPrevious {
    function iterateStart() public constant returns (uint);
    function iterateValid(uint keyIndex) public constant returns (bool);
    function iterateGet(uint keyIndex) public constant returns (address);
}

contract GxAdmins is GxCallableByDeploymentAdmin, GxEditable, GxAccounts {
    modifier callableByAdmin {
        if (isAdmin(msg.sender)) {
            _;
        } else {
            throw;
        }
    }

    modifier callableByAdminOrDeploymentAdmin {
        if (isDeploymentAdmin(msg.sender) || (isAdmin(msg.sender))) {
            _;
        } else {
             throw;
         }
    }

    // required for constructor signature
    function GxAdmins(address deploymentAdminsAddress) 
        GxCallableByDeploymentAdmin(deploymentAdminsAddress) {
        isEditable = true;
    }

    function upgrade(GxAdminsPrevious gxAdminsToUpgrade) callableByDeploymentAdmin public {

        // Deep upgrade, via copying previous data
        uint iterationNumber = gxAdminsToUpgrade.iterateStart();
        address iterationCurrent;
        while (gxAdminsToUpgrade.iterateValid(iterationNumber)) {
            iterationCurrent = gxAdminsToUpgrade.iterateGet(iterationNumber);
            this.add(iterationCurrent);
            iterationNumber++;
        }

    }

    function isAdmin(address accountAddress) public constant returns (bool _i) {
        return addresses.contains(accountAddress);
    }

    function add(address newAddress) callableByAdminOrDeploymentAdmin public {
        addresses.add(newAddress);
    }

    function remove(address removedAddress) callableByAdminOrDeploymentAdmin public {
        addresses.remove(removedAddress);
    }
}