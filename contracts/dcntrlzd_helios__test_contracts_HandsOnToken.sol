pragma solidity ^0.4.8;

import "./lib/Owned.sol";
import "./lib/TokenRecipient.sol";

contract HandsOnToken is Owned {
    /* Public variables of the token */
    string public standard = "Token 0.1";
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;

    /* This creates an array with all balances */
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;

    /* This generates a public event on the blockchain that will notify clients */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /* This notifies clients about the amount burnt */
    event Burn(address indexed from, uint256 value);

    /* Initializes contract with initial supply tokens to the creator of the contract */
    function HandsOnToken(
        uint256 initialSupply,
        string tokenName,
        uint8 decimalUnits,
        string tokenSymbol
    ) public {
        balanceOf[msg.sender] = initialSupply * (10 ** uint256(decimalUnits));  // Give the creator all initial tokens
        totalSupply = initialSupply;                                   // Update total supply
        name = tokenName;                                              // Set the name for display purposes
        symbol = tokenSymbol;                                          // Set the symbol for display purposes
        decimals = decimalUnits;                                       // Amount of decimals for display purposes
    }

    /* Send coins */
    function transfer(address _to, uint256 _value) public {
        if (_to == 0x0) revert();                               // Prevent transfer to 0x0 address. Use burn() instead
        if (balanceOf[msg.sender] < _value) revert();           // Check if the sender has enough
        if (balanceOf[_to] + _value < balanceOf[_to]) revert(); // Check for overflows
        balanceOf[msg.sender] -= _value;                     // Subtract from the sender
        balanceOf[_to] += _value;                            // Add the same to the recipient
        emit Transfer(msg.sender, _to, _value);                   // Notify anyone listening that this transfer took place
    }

    /* Allow another contract to spend some tokens in your behalf */
    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        return true;
    }

    /* Approve and then communicate the approved contract in a single tx */
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) public returns (bool success) {
        TokenRecipient spender = TokenRecipient(_spender);
        if (approve(_spender, _value)) {
            spender.receiveApproval(msg.sender, _value, this, _extraData);
            return true;
        }
    }

    /* A contract attempts to get the coins */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        if (_to == 0x0) revert();                                // Prevent transfer to 0x0 address. Use burn() instead
        if (balanceOf[_from] < _value) revert();                 // Check if the sender has enough
        if (balanceOf[_to] + _value < balanceOf[_to]) revert();  // Check for overflows
        if (_value > allowance[_from][msg.sender]) revert();     // Check allowance
        balanceOf[_from] -= _value;                           // Subtract from the sender
        balanceOf[_to] += _value;                             // Add the same to the recipient
        allowance[_from][msg.sender] -= _value;
        emit Transfer(_from, _to, _value);
        return true;
    }

    function burn(uint256 _value) public returns (bool success) {
        if (balanceOf[msg.sender] < _value) revert();            // Check if the sender has enough
        balanceOf[msg.sender] -= _value;                      // Subtract from the sender
        totalSupply -= _value;                                // Updates totalSupply
        emit Burn(msg.sender, _value);
        return true;
    }

    function burnFrom(address _from, uint256 _value) public returns (bool success) {
        if (balanceOf[_from] < _value) revert();                // Check if the sender has enough
        if (_value > allowance[_from][msg.sender]) revert();    // Check allowance
        balanceOf[_from] -= _value;                          // Subtract from the sender
        totalSupply -= _value;                               // Updates totalSupply
        emit Burn(_from, _value);
        return true;
    }

    function mint(uint256 _value) public onlyOwner returns (bool success) {
        uint256 amountToBeMinted = _value * (10 ** uint256(decimals));
        if (balanceOf[msg.sender] + amountToBeMinted < balanceOf[msg.sender]) revert();

        balanceOf[msg.sender] += amountToBeMinted;
        totalSupply += amountToBeMinted;

        emit Transfer(this, msg.sender, amountToBeMinted);                                   // Notify anyone listening that this transfer took place
        return true;
    }
}

contract ExchangeOffice is Owned {
    uint256 public exchangeRate;

    HandsOnToken public exchangeToken;

    function ExchangeOffice(
        uint256 initialExchangeRate,
        HandsOnToken addressOfExchangeToken
    ) public {
        exchangeRate = initialExchangeRate;
        exchangeToken = HandsOnToken(addressOfExchangeToken);
    }

    function () public payable {
        uint256 amountToBePaid = (exchangeRate * msg.value) / 1 ether;
        exchangeToken.transfer(msg.sender, amountToBePaid);
    }

    function depositEthers(address depositAddress) public onlyOwner {
        depositAddress.transfer(address(this).balance);
    }

    function depositTokens(address depositAddress) public onlyOwner {
        exchangeToken.transfer(depositAddress, exchangeToken.balanceOf(this));
    }

    function updateExchangeRate(uint256 _exchangeRate) public onlyOwner returns (bool success) {
        exchangeRate = _exchangeRate;
        return true;
    }
}
