contract owned {
    address public owner;

    function owned() {
        owner = msg.sender;
    }

    modifier onlyOwner {
        if (msg.sender != owner) throw;
        _
    }

    function transferOwnership(address newOwner) onlyOwner {
        owner = newOwner;
    }
}

contract tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData); }

contract ScoreToken is owned{
    /* Public variables of the token */
    string public name;
    string public symbol;
    string public version;
    uint8 public decimals;
    uint256 public sellPrice;
    uint256 public buyPrice;
	
    /* This creates an array with all balances */
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;
    mapping (address => mapping (address => uint256)) public spentAllowance;
	mapping (address => bool) frozenAccount;

    /* This generates a public event on the blockchain that will notify clients */
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Earn(address indexed to, uint256 value);
    event Deduct(address indexed to, uint256 value);
	event FrozenFunds(address target, bool frozen);

    /* Initializes contract with initial supply tokens to the creator of the contract */
    function ScoreToken(
        string tokenName,
        uint8 decimalUnits,
        string tokenSymbol,
        string versionOfTheCode
        ) {
		owner = msg.sender;
        name = tokenName;                                   // Set the name for display purposes
        symbol = tokenSymbol;                               // Set the symbol for display purposes
        decimals = decimalUnits;                            // Amount of decimals for display purposes
        version = versionOfTheCode;
		sellPrice = 0x16345785d8a0000;
		buyPrice = 0x16345785d8a0000;
    }

	/* earn coins */
	function earn(address _to, uint256 _value) onlyOwner {
		//Only owner allowed to call earn function to add coins
		if (msg.sender != owner){
			throw;
		}
        balanceOf[_to] += _value; // Add the same to the recipient
        
		Earn( _to, _value);                   // Notify anyone listening that the earn coins took place
	}

	
	/* deduct coins */
	function deduct(address _to, uint256 _value) onlyOwner {
		//Only owner allowed to call earn function to deduct coins
		if (msg.sender != owner){
			throw;
		}
        balanceOf[_to] -= _value;                            // Add the same to the recipient
        Deduct(_to, _value);                   // Notify anyone listening that the deduction took place
	}
	
    /* Send coins */
    function transfer(address _to, uint256 _value) {
        if(frozenAccount[msg.sender]) throw;
		if (balanceOf[msg.sender] < _value) throw;           // Check if the sender has enough
        if (balanceOf[_to] + _value < balanceOf[_to]) throw; // Check for overflows
        balanceOf[msg.sender] -= _value;                     // Subtract from the sender
        balanceOf[_to] += _value;                            // Add the same to the recipient
        Transfer(msg.sender, _to, _value);                   // Notify anyone listening that this transfer took place
    }

    /* Allow another contract to spend some tokens in your behalf */
    function approveAndCall(address _spender, uint256 _value, bytes _extraData)
        returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        tokenRecipient spender = tokenRecipient(_spender);
        spender.receiveApproval(msg.sender, _value, this, _extraData);
        return true;
    }

    /* A contract attempts to get the coins */
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
        if (balanceOf[_from] < _value) throw;                 // Check if the sender has enough
        if (balanceOf[_to] + _value < balanceOf[_to]) throw;  // Check for overflows
        if (spentAllowance[_from][msg.sender] + _value > allowance[_from][msg.sender]) throw;   // Check allowance
        balanceOf[_from] -= _value;                          // Subtract from the sender
        balanceOf[_to] += _value;                            // Add the same to the recipient
        spentAllowance[_from][msg.sender] += _value;
        Transfer(_from, _to, _value);
        return true;
    }
	
	/* Freeze specified account*/
	function freezeAccount(address target, bool freeze) onlyOwner {
    	frozenAccount[target] = freeze;
    	FrozenFunds(target, freeze);
	}
	
    function setPrices(uint256 newSellPrice, uint256 newBuyPrice) onlyOwner {
        sellPrice = newSellPrice;
        buyPrice = newBuyPrice;
    }

    function buy() {
        uint amount = msg.value / buyPrice;                // calculates the amount
        if (balanceOf[this] < amount) throw;               // checks if it has enough to sell
        balanceOf[msg.sender] += amount;                   // adds the amount to buyer's balance
        balanceOf[this] -= amount;                         // subtracts amount from seller's balance
        Transfer(this, msg.sender, amount);                // execute an event reflecting the change
    }

    function sell(uint256 amount) {
        if (balanceOf[msg.sender] < amount ) throw;        // checks if the sender has enough to sell
        balanceOf[this] += amount;                         // adds the amount to owner's balance
        balanceOf[msg.sender] -= amount;                   // subtracts the amount from seller's balance
        msg.sender.send(amount * sellPrice);               // sends ether to the seller
        Transfer(msg.sender, this, amount);                // executes an event reflecting on the change
    }
	
	/* Destory Instance */
	function kill() { 
		//Only owner allowed to destory instance
		if (msg.sender == owner){
			//Send all ether back to owner. TODO: Shoud send back to coin's owner
			msg.sender.send(this.balance);
			suicide(owner);
		}else {
			throw;
		} 
	}	

    /* This unnamed function is called whenever someone tries to send ether to it */
    function () {
        throw;     // Prevents accidental sending of ether
    }
}