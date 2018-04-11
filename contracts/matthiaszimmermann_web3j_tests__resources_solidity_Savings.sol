pragma solidity ^0.4.2;

contract Savings {
    
	uint public limit;
	uint public period;
	address owner;
	uint lastWithdrawal;

    event Deposit(uint value, address from);
    event Withdrawal(uint value, string message);
    
    modifier onlyowner { if (msg.sender == owner) _ ; }
    
    // constructor
    function Savings(uint limitWei, uint periodSeconds) {
        owner = msg.sender;
        limit = limitWei;
        period = periodSeconds;
    }
    
    // makes savings contract accept ethers
	function() public payable { 
	    Deposit(msg.value, msg.sender);
	}
	
	// withdraw funds, enforces limit and time period
	function withdraw(uint amountWei) public onlyowner() {
		// enforce limit
		if(amountWei > limit) {
		    Withdrawal(amountWei, "ERR_LIMIT"); 
		}
		// verify time since last withdrawal
		else if(now - lastWithdrawal < period * 1 seconds) {
		    Withdrawal(amountWei, "ERR_PERIOD"); 
		}
		// try to withdraw funds
		else if(!owner.send(amountWei)) {
		    Withdrawal(amountWei, "ERR_SEND");
		}
		// happy case
		else {
	        lastWithdrawal = now;
		    Withdrawal(amountWei, "OK");
		}
	}
    
    function kill() public onlyowner() { 
        selfdestruct(owner); 
    }
}