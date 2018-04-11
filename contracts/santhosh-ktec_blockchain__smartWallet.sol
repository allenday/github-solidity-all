pragma solidity ^0.4.11;

contract smartWallet {
	address public owner;
	
	mapping (address => uint) balances;
	
	//constructor, will be called only once . When new wallet/coinbase is created
	function smartWallet() {
		owner = msg.sender;
		balances[msg.sender] = 1000000;
	}
	
	//method to transfer some amount to some other's account
	function transferAmount(address receiver, uint amount) returns(bool sufficient) {
		if (balances[msg.sender] < amount) return false;
		balances[msg.sender] -= amount;
		balances[receiver] += amount;
		return true;
	}
	
	//method to get account balance
	function getBalance() returns(uint bal) {
		return balances[msg.sender];
	}
}