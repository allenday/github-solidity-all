pragma solidity ^0.4.2;

import './GxCallableByDeploymentAdmin.sol';

import './GxTradersInterface.sol';


contract GxUsesTraders is GxCallableByDeploymentAdmin {
	GxTradersInterface public traders;

	function setTradersContract(address tradersAddress) public callableByDeploymentAdmin {
		traders = GxTradersInterface(tradersAddress);
	}
}