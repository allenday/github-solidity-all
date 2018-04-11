pragma solidity ^0.4.2;

import './GxCallableByDeploymentAdmin.sol';
import './GxOwnedIterable.sol';
import './GxVersioned.sol';
import './GxManagedWalletInterface.sol';


contract GxManagedWallet is GxCallableByDeploymentAdmin, GxVersioned, GxOwnedIterable, GxManagedWalletInterface {
    event Pay(address indexed _recipient, uint _amount);

    function GxManagedWallet(address deploymentAdminsAddress) 
        GxCallableByDeploymentAdmin(deploymentAdminsAddress) 
    {
        
    }

    function() payable {
        // do nothing
    }

    function pay(address _recipient, uint _amount) public callableByOwner returns (bool)   {
        if (_recipient.call.value(_amount)()) {
            // raise the event
            Pay(_recipient, _amount);
            return true;
        } else {
            return false;
        }
    }
}