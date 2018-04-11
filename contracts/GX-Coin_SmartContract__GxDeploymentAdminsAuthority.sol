pragma solidity ^0.4.2;

import './GxAuth.sol';
import './GxAccountsInterface.sol';
import './GxAuthority.sol';


contract GxDeploymentAdminsAuthority is GxAuthority, GxAuth
{
    GxAccountsInterface public deploymentAdmins;

    function setDeploymentAdminsContract(address _deploymentAdmins) public auth() {
        deploymentAdmins = GxAccountsInterface(_deploymentAdmins);
    }

    function canCall(address caller_address, address code_address, bytes4 sig) constant returns (bool) {
        return deploymentAdmins.contains(caller_address);
    }
}