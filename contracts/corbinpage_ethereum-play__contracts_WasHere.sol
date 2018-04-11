pragma solidity ^0.4.3;

contract WasHere {
	mapping (address => string) names;
	address owner;

	modifier onlyOwner {
    if (msg.sender != owner)
      throw;
    _;
  }

	function WasHere() {
		names[tx.origin] = "HelloWorld";
		owner = msg.sender;
	}

	function getName() constant returns(string) {
		string memory name = "No name found.";

		// if(bytes(names[addr]).length != 0 ) {
		//  name = names[addr];
		// }
		return name;
	}

	// event Transfer(address indexed _from, address indexed _to, uint256 _value);

	// function MetaCoin() {
	// 	balances[tx.origin] = 10000;
	// }

	// function sendCoin(address receiver, uint amount) returns(bool sufficient) {
	// 	if (balances[msg.sender] < amount) return false;
	// 	balances[msg.sender] -= amount;
	//	balances[receiver] += amount;
	//	Transfer(msg.sender, receiver, amount);
	//	return true;
	// }

	// function getBalanceInEth(address addr) returns(uint){
	//	return ConvertLib.convert(getBalance(addr),2);
	// }

	// function getBalance(address addr) returns(uint) {
	// 	return balances[addr];
	// }
}
