pragma solidity ^0.4.2;

import './GxCallableByDeploymentAdmin.sol';

import './GxConstants.sol';


contract GxUsesConstants is GxCallableByDeploymentAdmin {
	GxConstants public constants;

	function setConstantsContract(address constantsAddress) public callableByDeploymentAdmin {
		constants = GxConstants(constantsAddress);
	}
}