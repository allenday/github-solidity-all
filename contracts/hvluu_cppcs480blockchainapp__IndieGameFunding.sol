pragma solidity 0.4.11;

contract owned {
	address public owner;
	
	function owned() {
		owner = msg.sender;
	}
	
	modifier onlyOwner {
		if(msg.sender != owner) throw;
		_;
	}
	
	function transferOwnership(address newOwner) onlyOwner {
		owner = newOwner;
	}
}

contract IndieGameToken is owned {
	/* Public variable of the token */
	string public name;
	string public symbol;
	uint8 public decimals;
	uint256 public totalSupply;
	
    	/* An array with all account balances */
    	mapping (address => uint256) public balanceOf;

	/* Events */
	event Transfer(address indexed from, address indexed to, uint256 value);
	
    	/* Initializes contract with initial supply tokens to the creator of the contract */
    	function IndieGameToken(
		string _name,
		string _symbol,
		uint8 _decimals,
		uint256 _initialSupply,
		address _owner) {
                      
		name = _name;
		symbol = _symbol;
		decimals = _decimals;
		totalSupply = _initialSupply;
		if(_owner != 0) owner = _owner;
    	}

    	/* Send tokens */
    	function transfer(address _to, uint256 _value) {
		if (_to == 0x0) throw;
		if (balanceOf[msg.sender] < _value) throw;           
		if (balanceOf[_to] + _value < balanceOf[_to]) throw; 
		balanceOf[msg.sender] -= _value;                     
		balanceOf[_to] += _value;                            
			Transfer(msg.sender, _to, _value);
   	}
	
	/* Generate more tokens */
	function mintToken(address _target, uint256 _mintedAmount) onlyOwner {
		balanceOf[_target] += _mintedAmount;
		totalSupply += _mintedAmount;
		Transfer(0, owner, _mintedAmount);
		Transfer(owner, _target, _mintedAmount);
	}
}

contract IndieGameFunding {
	
	/* Public variables of the contract */
	address public beneficiary;
	uint public fundingGoal;
	uint public amountRaised;
	uint public deadline;
	uint public price;
	bool goalReached = false;
	bool fundingClosed = false;
	
	IndieGameToken public reward;
	
	/* An array with all account balances */
	mapping(address => uint256) public balanceOf;
	
	/* Events */
	event GoalReached(address beneficiary, uint amountRaised);
	event FundTransfer(address backer, uint amount, bool isContribution);
	
	/* Modifiers */
	modifier afterDeadline() { if (now >= deadline) _; }
	
	/* Default constructor */
	function IndieGameFunding(
		address _beneficiary, 
		uint _fundingGoalInEthers, 
		uint _fundingTimeInMins, 
		uint _costPerTokenInEthers,
		IndieGameToken _addressOfToken) {
		
		beneficiary = _beneficiary;
		fundingGoal = _fundingGoalInEthers * 1 ether;
		deadline = _fundingTimeInMins * 1 minutes + now;
		price = _costPerTokenInEthers * 1 ether;
		reward = IndieGameToken(_addressOfToken);
	}
	
	function () payable {
		if (fundingClosed) throw;
		uint amount = msg.value;
		balanceOf[msg.sender] = amount;
		amountRaised += amount;
		reward.mintToken(msg.sender, amount/price);
		FundTransfer(msg.sender, amount, true);
	}
	
	function isGoalReached() afterDeadline {
		if (amountRaised >= fundingGoal) {
			goalReached = true;
			GoalReached (beneficiary, amountRaised);
		}
		fundingClosed = true;
	}
	
	function fundTransfer() afterDeadline {
		if (!goalReached) {
			uint amount = balanceOf[msg.sender];
			balanceOf[msg.sender] = 0;
			if (amount > 0) {
				if (msg.sender.send(amount)) {
					FundTransfer(msg.sender, amount, false);
				} else {
					balanceOf[msg.sender] = amount;
				}
			}
		}
		
		if (goalReached && beneficiary == msg.sender) {
			if (beneficiary.send(amountRaised)) {
				FundTransfer(beneficiary, amountRaised, false);
			} else {
				goalReached = false;
			}
		}
		fundingClosed = true;
	}
}
