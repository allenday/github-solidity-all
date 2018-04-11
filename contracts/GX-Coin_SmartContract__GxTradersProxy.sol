pragma solidity ^0.4.2;

import './GxCallableByDeploymentAdmin.sol';
import './GxOwnedIterable.sol';
import './GxUsesAdmins.sol';
import './GxUsesTraders.sol';


contract GxTradersProxy is GxCallableByDeploymentAdmin, GxOwnedIterable, GxUsesTraders, GxUsesAdmins {
    function GxTradersProxy(address deploymentAdminsAddress) 
    	GxCallableByDeploymentAdmin(deploymentAdminsAddress) 
	{

    }

    function add(address newAddress) public callableByOwner {
        traders.add(newAddress);
    }

    function remove(address removedAddress) public callableByOwner {
        traders.remove(removedAddress);
    }

    function setDollarBalance(address mappedAddress, int160 dollarBalance) public callableByOwner {
        traders.setDollarBalance(mappedAddress, dollarBalance);
    }

    function setCoinBalance(address mappedAddress, uint32 coinBalance) public callableByOwner {
        traders.setCoinBalance(mappedAddress, coinBalance);
    }

    function addCoinAmount(address mappedAddress, uint32 coinAmount) public callableByOwner {
        traders.addCoinAmount(mappedAddress, coinAmount);
    }

    function addDollarAmount(address mappedAddress, int160 dollarAmount) public callableByOwner {
        traders.addDollarAmount(mappedAddress, dollarAmount);
    }
}