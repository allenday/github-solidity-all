pragma solidity ^0.4.6;
contract RedFoo {
 mapping (address => uint) balances;

  event SendFoo(address indexed _from, address indexed _to, uint256 _value, bytes _hash , uint _timestamp);
  function RedFoo() {
      	balances[msg.sender] = 100;
  }

  function balanceOf(address _owner) constant returns (uint256 balance) {
        return balances[_owner];
  }

  function sendFoo(address _to, uint256 _value, bytes _hash) returns (bool success) {
		if (_value > 0) {
			balances[msg.sender] += _value;
			balances[_to] += _value;
			SendFoo(msg.sender, _to , _value, _hash, now);
			return true;
		} else { return false; }
	}
}
