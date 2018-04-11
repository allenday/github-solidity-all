pragma solidity ^0.4.2;

import './GxCallableByDeploymentAdmin.sol';
import './GxAccountsInterface.sol';


// Implements "callableByAdmin" modifier
contract GxUsesAdmins is GxCallableByDeploymentAdmin {
    GxAccountsInterface public admins;

    function setAdminsContract(address adminsAddress) public callableByDeploymentAdmin {
        admins = GxAccountsInterface(adminsAddress);
    }
}
