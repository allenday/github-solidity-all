pragma solidity ^0.4.15;

import './CBIToken.sol';
//import 'zeppelin-solidity/contracts/crowdsale/Crowdsale.sol';
import 'zeppelin-solidity/contracts/crowdsale/CappedCrowdsale.sol';
//import 'zeppelin-solidity/contracts/crowdsale/RefundableCrowdsale.sol';


contract CBITokenCrowdsale is CappedCrowdsale, RefundableCrowdsale { 
	function CBITokenCrowdsale(uint256 _startTime, uint256 _endTime, uint256 _rate, uint256 _goal, uint256 _cap, address _wallet)
		CappedCrowdsale(_cap)
		FinalizableCrowdsale()
		RefundableCrowdsale(_goal)
		Crowdsale(_startTime, _endTime, _rate, _wallet) {
			require(_goal <=_cap);
		}

	//Create token
	function createTokenContract() internal returns (MintableToken) {
		return new CBIToken();
	}
}