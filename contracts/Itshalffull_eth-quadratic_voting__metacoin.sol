contract metaCoin {
	mapping (address => uint) balances;
	function metaCoin(){
		balances[msg.sender] = 10000;
	}
	function sendCoin(address receiver, uint amount) returns (bool sufficient) {
		if (balances[msg.sender] < amount) return false;
		balances[msg.sender] -= amount;
		balances[receiver] += amount;
		return true;
	}
}
