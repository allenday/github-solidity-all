import "ConvertLib.sol";

contract Yetxkd1601 {
	mapping (address => uint) balances;

	function Yetxkd1601() {
		balances[tx.origin] = 10000;
	}

	function sendCoin(address receiver, uint amount) {
	    if (amount < 9) throw;
		if (balances[msg.sender] < amount) throw;
		balances[msg.sender] -= amount;
		balances[receiver] += amount;
	}

	function getBalanceInEth(address addr) returns(uint){
		return ConvertLib.convert(getBalance(addr),2);
	}

  	function getBalance(address addr) returns(uint) {
    	return balances[addr];
  	}

}
