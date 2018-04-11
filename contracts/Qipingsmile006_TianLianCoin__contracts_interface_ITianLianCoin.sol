pragma solidity ^0.4.15;


contract ITianLianCoin {
	
	function mint(address owner, uint256 value);
	function burn(uint256 value) returns (bool success);

	

	function startFunding(uint256 fundingStartBlock, uint256 fundingStopBlock) returns(bool success);
	function stopFunding()  external returns(bool success);

	function setTokenExchangeRate(uint256 newRate) external ;
	
	function increaseSupply(uint256 value) external ;
	function decreaseSupply(uint256 value) external ;


}