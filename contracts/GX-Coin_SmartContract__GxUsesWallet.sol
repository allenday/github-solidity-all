pragma solidity ^0.4.2;

import './GxCallableByDeploymentAdmin.sol';

import './GxManagedWalletInterface.sol';


contract GxUsesWallet is GxCallableByDeploymentAdmin {
	GxManagedWalletInterface public wallet;

    function setWalletContract(address walletAddress) public callableByDeploymentAdmin {
        wallet = GxManagedWalletInterface(walletAddress);
    }
}