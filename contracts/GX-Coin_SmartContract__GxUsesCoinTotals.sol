pragma solidity ^0.4.2;

import './GxCallableByDeploymentAdmin.sol';

import './GxCoinTotalsInterface.sol';


contract GxUsesCoinTotals is GxCallableByDeploymentAdmin {
	GxCoinTotalsInterface public coinTotals;

    function setCoinTotalsContract(address coinTotalsAddress) public callableByDeploymentAdmin {
        coinTotals = GxCoinTotalsInterface(coinTotalsAddress);
    }
}