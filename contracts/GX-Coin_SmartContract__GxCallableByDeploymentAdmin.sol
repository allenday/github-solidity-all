pragma solidity ^0.4.2;

import './GxAccountsInterface.sol';


// Implements "callableByDeploymentAdmin" modifier
contract GxCallableByDeploymentAdmin {
    GxAccountsInterface public deploymentAdmins;

    function GxCallableByDeploymentAdmin(address deploymentAdminsAddress) {
        if (deploymentAdminsAddress == 0x0) {
            throw;
        }
        deploymentAdmins = GxAccountsInterface(deploymentAdminsAddress);
    }

    modifier callableByDeploymentAdmin {
        if (isDeploymentAdmin(msg.sender)) {
            _;
        } else {
            throw;
        }
    }

    function isDeploymentAdmin(address accountAddress) public constant returns (bool _i) {
        return deploymentAdmins.contains(accountAddress);
    }

    function setDeploymentAdminsContract(address newDeploymentAdmins) public callableByDeploymentAdmin {
        deploymentAdmins = GxAccountsInterface(newDeploymentAdmins);
    }

    // Function to recover the funds on the contract
    function kill() callableByDeploymentAdmin {
        selfdestruct(msg.sender);
    }
}
