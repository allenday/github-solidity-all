import "Coin";
import "named";
import "owned";
import "coin";

contract PropertyToken is Coin, named("Estate"), coin("EST", 5), owned {
	address miner;
    uint lastBlockMined;
	mapping (address => uint) tokens;
    mapping (address => mapping (address => bool)) approved;
	
	function propertyToken() {
		owner = msg.sender;
		miner = owner;
		tokens[owner] = 10;		
        lastBlockMined = block.number;		
	}
	
	function remove() {
		if (msg.sender == owner)
			suicide(owner);
	}
	
	function mine(address owner) {
		if (msg.sender != miner) {
			return;
        }
	
        tokens[block.coinbase] += 1;
        lastBlockMined = block.number;
	}

    function approve(address addr) {
        approved[msg.sender][addr] = true;
    }

    function isApproved(address addr) constant returns (bool approval) {
        return approved[msg.sender][addr];
    }
	
	function sendPToken(address receiver, uint amount) returns (bool sufficient) {
		if (tokens[msg.sender] < amount) {
			return false;
        }

		tokens[msg.sender] -= amount;
		tokens[receiver] += amount;
		
		return true;
	}

    function sendPTokenFrom(address sender, uint amount, address receiver) returns (bool sufficient) {
        if (tokens[sender] < amount && !approved[sender][msg.sender]) {
            return false;
        }

        tokens[sender] -= amount;
        tokens[receiver] += amount;
		
		return true;
    }
	
    function queryTokens() constant returns (uint token) {
        return tokens[msg.sender];
    }

	function queryTokensOf(address addr) constant returns (uint token) {
		return tokens[addr];
	}
}
