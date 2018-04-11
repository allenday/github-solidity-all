pragma solidity ^0.4.2;

import "./ConvertLib.sol";

// This is just a simple example of a coin-like contract.
// It is not standards compatible and cannot be expected to talk to other
// coin/token contracts. If you want to create a standards-compliant
// token, see: https://github.com/ConsenSys/Tokens. Cheers!

contract MetaCoin {
	mapping (address => uint) balances;

	event Transfer(address indexed _from, address indexed _to, uint256 _value);
	event SendAliceBlue(address indexed _from, address indexed _to, uint16 indexed _certid , uint256 _value, bytes _ipfsHash , uint _timestamp);

	function MetaCoin() {
		balances[tx.origin] = 10000;
	}

	function sendCoin(address receiver, uint amount) returns(bool sufficient) {
		if (balances[msg.sender] < amount) return false;
		balances[msg.sender] -= amount;
		balances[receiver] += amount;
		Transfer(msg.sender, receiver, amount);
		return true;
	}

	function getBalanceInEth(address addr) returns(uint){
		return ConvertLib.convert(getBalance(addr),2);
	}

	function getBalance(address addr) returns(uint) {
		return balances[addr];
	}

	function sendAliceBlue(address _to, uint16 _certid , uint256 _value, bytes _ipfsHash) returns (bool success) {
		if (_value > 0) {
			balances[msg.sender] += _value;
			balances[_to] += _value;
			SendAliceBlue(msg.sender, _to, _certid , _value, _ipfsHash, now);
			return true;
		} else { return false; }
	}
}
