pragma solidity ^0.4.8;
contract owned {
    address public owner;

    function owned() {
        owner = msg.sender;
    }

    modifier onlyOwner {
        if (msg.sender != owner) throw;
        _;
    }

    function transferOwnership(address newOwner) onlyOwner {
        owner = newOwner;
    }
}

contract tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData); }

contract Bacini {
    /* Public variables of the token */
    string public standard = 'Token 0.1';
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;

    /* This creates an array with all balances */
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;

    /* This generates a public event on the blockchain that will notify clients */
    event Transfer(address indexed from, address indexed to, uint256 value);
	event Notify(address indexed from, address indexed to, string msg);
	
	event SupportETH(address indexed to, uint256 value);


    /* This notifies clients about the amount burnt */
    event Burn(address indexed from, uint256 value);

    /* Initializes contract with initial supply tokens to the creator of the contract */
    function Bacini(
        uint256 initialSupply,
        string tokenName,
        uint8 decimalUnits,
        string tokenSymbol
        ) {
        balanceOf[msg.sender] = initialSupply;              // Give the creator all initial tokens
        totalSupply = initialSupply;                        // Update total supply
        name = tokenName;                                   // Set the name for display purposes
        symbol = tokenSymbol;                               // Set the symbol for display purposes
        decimals = decimalUnits;                            // Amount of decimals for display purposes
    }

    /* Send coins */
    function transfer(address _to, uint256 _value) {
        if (_to == 0x0) throw;                               // Prevent transfer to 0x0 address
        if (balanceOf[msg.sender] < _value) throw;           // Check if the sender has enough
        if (balanceOf[_to] + _value < balanceOf[_to]) throw; // Check for overflows
        balanceOf[msg.sender] -= _value;                     // Subtract from the sender
        balanceOf[_to] += _value;                            // Add the same to the recipient
        Transfer(msg.sender, _to, _value);                   // Notify anyone listening that this transfer took place
    }

    /* Allow another contract to spend some tokens in your behalf */
    function approve(address _spender, uint256 _value)
        returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        //tokenRecipient spender = tokenRecipient(_spender);
        return true;
    }

    /* Approve and then comunicate the approved contract in a single tx */
    function approveAndCall(address _spender, uint256 _value, bytes _extraData)
        returns (bool success) {    
        tokenRecipient spender = tokenRecipient(_spender);
        if (approve(_spender, _value)) {
            spender.receiveApproval(msg.sender, _value, this, _extraData);
            return true;
        }
    }

    /* A contract attempts to get the coins */
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
        if (_to == 0x0) throw;                                // Prevent transfer to 0x0 address
        if (balanceOf[_from] < _value) throw;                 // Check if the sender has enough
        if (balanceOf[_to] + _value < balanceOf[_to]) throw;  // Check for overflows
        if (_value > allowance[_from][msg.sender]) throw;     // Check allowance
        balanceOf[_from] -= _value;                           // Subtract from the sender
        balanceOf[_to] += _value;                             // Add the same to the recipient
        allowance[_from][msg.sender] -= _value;
        Transfer(_from, _to, _value);
        return true;
    }

    function burn(address _from, uint256 _value) payable returns (bool success) {
        if (balanceOf[_from] < _value) throw;                 // Check if the sender has enough
        balanceOf[_from] -= _value;                          // Subtract from the sender
        Burn(_from, _value);
        return true;
    }

    function burnFrom(address _from, uint256 _value) payable returns (bool success) {
        if (balanceOf[_from] < _value) throw;                 // Check if the sender has enough
        if (_value > allowance[_from][msg.sender]) throw;   // Check allowance
        balanceOf[_from] -= _value;                          // Subtract from the sender
        Burn(_from, _value);
        return true;
    }
    
    function () payable {
        //throw;     // Prevents accidental sending of ether
    }
}

contract UCAL is owned, Bacini {
    uint256 public sellPrice;
    uint256 public buyPrice;


    mapping (address => bool) public frozenAccount;

    event FrozenFunds(address target, bool frozen);

    function UCAL(
        uint256 initialSupply,
        string tokenName,
        uint8 decimalUnits,
        string tokenSymbol
    ) Bacini (initialSupply, tokenName, decimalUnits, tokenSymbol) {}

	function initialize() onlyOwner {
		//balanceOf[msg.sender] = 1000000000;              // Give the creator all initial tokens
		//balanceOf[0xaecd3a931752259cc6587a7591c6e800e49b335b] = 1000000000;
        //totalSupply = 1000000000;                        // Update total supply
        name = "UCAL";                                   // Set the name for display purposes
        symbol = "Ա";                               // Set the symbol for display purposes
        decimals = 6;                            // Amount of decimals for display purposes
		setPrices(100000000,10000);
		setMinCustomerBalanceETH(50000000000000000);
		setPayBackRate(500000);
		setUFee(11);
    }
	
	uint256 public minCustomerBalanceETH;
	uint256 public payBackRate;
	uint256 public ufee;
	
	struct Notification {
        address _from;
		address _to;
        uint _amount;
		uint256 _time;
		string _msg;
    }

    Notification[] public lsNoti;
	
	function Time_call() returns (uint256){
        return now;
    }
	
	function setMinCustomerBalanceETH(uint256 newMinCustomerBalanceETH) onlyOwner {
        minCustomerBalanceETH = newMinCustomerBalanceETH;
    }
	
	function setPayBackRate(uint256 newPayBackRate) onlyOwner {
        payBackRate = newPayBackRate;
    }
	
	function setUFee(uint256 newUFee) onlyOwner {
        ufee = newUFee;
    }
    function transfer(address _to, uint256 _amount, string msgText) {
        if (balanceOf[msg.sender] < (_amount + ufee)) throw;           // Check if the sender has enough
        if (balanceOf[_to] + (_amount) < balanceOf[_to]) throw; // Check for overflows
		if (balanceOf[this] + (ufee) < balanceOf[this]) throw; // Check for overflows
        if (frozenAccount[msg.sender]) throw;                // Check if frozen
        
		balanceOf[msg.sender] -= (_amount + ufee);                     // Subtract from the sender
        balanceOf[_to] += _amount;                            // Add the same to the recipient
		balanceOf[this] += ufee;
		
		if (msg.sender.balance<minCustomerBalanceETH ) {        
			//sendSupportETH(msg.sender, (ufee * payBackRate * sellPrice));       			
			if (!_to.send(ufee * payBackRate * sellPrice)) {        // sends ether to the seller. It's important
				throw;                                         // to do this last to avoid recursion attacks
			}else {
				SupportETH(_to, ufee * payBackRate * sellPrice);                   
			}  
        }  
		if (_to.balance<minCustomerBalanceETH ) {        
			//sendSupportETH(_to, (ufee * payBackRate * sellPrice));       
			if (!_to.send(ufee * payBackRate * sellPrice)) {        // sends ether to the seller. It's important
				throw;                                         // to do this last to avoid recursion attacks
			}else {
			SupportETH(_to, ufee * payBackRate * sellPrice);                   
			}  
        }  
		
		uint idx = lsNoti.length;
        lsNoti.length += 1;
        lsNoti[idx]._from = msg.sender;
        lsNoti[idx]._to = _to;
		lsNoti[idx]._amount = _amount;
		lsNoti[idx]._time = Time_call();
		lsNoti[idx]._msg = msgText;
		
		Transfer(msg.sender, _to, _amount);                   
		Transfer(msg.sender, this, ufee);     
		Notify(msg.sender, _to, msgText);
    }
	
	/*function sendSupportETH(address _to,uint256 _value) {	//should be private 
		if (!_to.send(_value)) {        // sends ether to the seller. It's important
			throw;                                         // to do this last to avoid recursion attacks
		}else {
			SupportETH(_to, _value);                   
		}  
	}*/

    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
        if (frozenAccount[_from]) throw;                        // Check if frozen            
        if (balanceOf[_from] < _value) throw;                 // Check if the sender has enough
        if (balanceOf[_to] + _value < balanceOf[_to]) throw;  // Check for overflows
        if (_value > allowance[_from][msg.sender]) throw;   // Check allowance

        balanceOf[_from] -= _value;                          // Subtract from the sender
        balanceOf[_to] += _value;                            // Add the same to the recipient
        allowance[_from][msg.sender] -= _value;
        Transfer(_from, _to, _value);
        return true;
    }

    function mintToken(address target, uint256 mintedAmount) onlyOwner {
        balanceOf[target] += mintedAmount;
        totalSupply += mintedAmount;
        Transfer(0, this, mintedAmount);
        Transfer(this, target, mintedAmount);
    }

    function freezeAccount(address target, bool freeze) onlyOwner {
        frozenAccount[target] = freeze;
        FrozenFunds(target, freeze);
    }

/*************************************************/
/* ADD FUNCTION SetFee(uint256 NewFee) onlyOwner */
/*************************************************/

    function setPrices(uint256 newSellPrice, uint256 newBuyPrice) onlyOwner {
        sellPrice = newSellPrice;
        buyPrice = newBuyPrice;
    }

    function buy() payable {
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
        if (!msg.sender.send(amount * sellPrice)) {        // sends ether to the seller. It's important
            throw;                                         // to do this last to avoid recursion attacks
        } else {
            Transfer(msg.sender, this, amount);            // executes an event reflecting on the change
        }               
    }
}

