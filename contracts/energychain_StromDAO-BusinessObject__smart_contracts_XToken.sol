pragma solidity ^0.4.13;
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

contract token is owned {
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

    /* Initializes contract with initial supply tokens to the creator of the contract */
    function token(
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

	function issue(uint256 _value) onlyOwner {
			totalSupply+=_value;
			balanceOf[msg.sender]+=_value;
	}
    /* Send coins */
    function transfer(address _to, uint256 _value) {
        if (balanceOf[msg.sender] < _value) throw;           // Check if the sender has enough
        if (balanceOf[_to] + _value < balanceOf[_to]) throw; // Check for overflows
        balanceOf[msg.sender] -= _value;                     // Subtract from the sender
        balanceOf[_to] += _value;                            // Add the same to the recipient
        Transfer(msg.sender, _to, _value);                   // Notify anyone listening that this transfer took place
    }

    function () {
        throw;     // Prevents accidental sending of ether
    }
}

contract XTokenFactory {
	event Built(address _mpd,address _account);

	function build() returns(XToken) {
		XToken mpdelta = new XToken();
		Built(address(mpdelta),msg.sender);
		mpdelta.transferOwnership(msg.sender);
		return mpdelta;
	}
	
}

contract XToken is owned {
	
	/* Public variables of the token */
    string public standard = 'Token 0.1';
    string public name='XToken';
    string public symbol='X2';
    uint8 public decimals=4;
    uint256 public totalSupply=0;
    
    mapping (address => uint256) public rates;
    mapping (address => mapping(address => uint256)) public allocations;
	function setRate(token _token,uint256 rate) onlyOwner {
		rates[_token]=rate;
	}	
	
	function x(token from_token) {
		if(from_token.balanceOf(this)<allocations[from_token][msg.sender]) revert();		
		uint256 amount=allocations[from_token][msg.sender];		
		balanceOf[msg.sender]+=amount*rates[from_token];		
		totalSupply+=amount*rates[from_token];		
		allocations[from_token][msg.sender]=0;
	}
	
	function allocate(token from_token,uint256 amount) {		
			if(from_token.balanceOf(msg.sender)<amount) revert();
			allocations[from_token][msg.sender]=amount;
	}
	


    /* This creates an array with all balances */
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;

    /* This generates a public event on the blockchain that will notify clients */
    event Transfer(address indexed from, address indexed to, uint256 value);
    

    /* Send coins */
    function transfer(address _to, uint256 _value) {
        if (balanceOf[msg.sender] < _value) throw;           // Check if the sender has enough
        if (balanceOf[_to] + _value < balanceOf[_to]) throw; // Check for overflows
        balanceOf[msg.sender] -= _value;                     // Subtract from the sender
        balanceOf[_to] += _value;                            // Add the same to the recipient
        Transfer(msg.sender, _to, _value);                   // Notify anyone listening that this transfer took place
    }

    function () {
        throw;     // Prevents accidental sending of ether
    }
}
