pragma solidity ^0.4.2;

import './GxVersioned.sol';
import './GxAccounts.sol';


contract GxDeploymentAdmins is GxVersioned, GxAccounts {

    function GxDeploymentAdmins() {
        addresses.add(msg.sender);
    }

    modifier callableByDeploymentAdmin {
        if (addresses.contains(msg.sender)) {
            _;
        } else {
            throw;
        }
    }

    function add(address newAddress) callableByDeploymentAdmin public {
        addresses.add(newAddress);
    }

    function remove(address removedAddress) callableByDeploymentAdmin public {
        addresses.remove(removedAddress);
    }
}