pragma solidity ^0.4.6;

/**
 * The cryptoRennder contract does this and that...
 */
contract cryptoRennder {
mapping (address => uint) cryptoBalance;

	struct wallet {
		address msg.sender;
		uint cryptoCoins;
		uint Unicorn;
	}
	

		wallet mainFund;
		
	function giveCrypto () {
		cryptoBalance[msg.sender] = 999;
		mainFund.cryptoCoins = 1099099;
		mainFund.Unicorn = 992;
		

	}	

	function sendCrypto (address receiver, uint amount) returns(bool res) {
		if (cryptoBalance[msg.sender] < amount) return false;
		cryptoBalance[msg.sender] -= amount;
		cryptoBalance[receiver]+= amount;
		return true;
		
	}
	
}
