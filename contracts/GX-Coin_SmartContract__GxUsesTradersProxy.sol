pragma solidity ^0.4.2;

import './GxCallableByDeploymentAdmin.sol';

import './GxTradersProxy.sol';


contract GxUsesTradersProxy is GxCallableByDeploymentAdmin {
	GxTradersProxy public tradersProxy;

	function setTradersProxyContract(address tradersProxyAddress) public callableByDeploymentAdmin {
		tradersProxy = GxTradersProxy(tradersProxyAddress);
	}
}