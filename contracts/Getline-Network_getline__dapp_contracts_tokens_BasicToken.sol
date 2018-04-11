/* from https://www.ethereum.org/token */

pragma solidity ^0.4.11;

import "./IToken.sol";


contract BasicToken is IToken {
    string public name;
    string public symbol;
    uint256 public decimals;

    uint256 internal totalSupplyField;

    /* This creates an array with all balances */
    mapping (address => uint256) internal balanceOfField;
    mapping (address => mapping (address => uint256)) internal allowanceField;

    function BasicToken(
        uint256 initialSupply,
        string tokenName,
        uint256 decimalUnits,
        string tokenSymbol
        ) public
    {
        totalSupplyField = initialSupply;                        // Update total supply
        name = tokenName;                                   // Set the name for display purposes
        symbol = tokenSymbol;                               // Set the symbol for display purposes
        decimals = decimalUnits;                            // Amount of decimals for display purposes
    }

    function totalSupply() constant public returns (uint) {
        return totalSupplyField;
    }

    function balanceOf(address _owner) constant public returns (uint256 balance) {
        return balanceOfField[_owner];
    }

    function allowance(address _owner, address _spender) constant public returns (uint256 _allowance) {
        return allowanceField[_owner][_spender];
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(_to != 0x0);                               // Prevent transfer to 0x0 address. Use burn() instead
        require(balanceOfField[msg.sender] >= _value);           // Check if the sender has enough
        require(balanceOfField[_to] + _value >= balanceOfField[_to]); // Check for overflows

        balanceOfField[msg.sender] -= _value;                     // Subtract from the sender
        balanceOfField[_to] += _value;                            // Add the same to the recipient
        Transfer(msg.sender, _to, _value);                   // Notify anyone listening that this transfer took place
        return true;
    }

    /* Allow another contract to spend some tokens in your behalf */
    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowanceField[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }      

    /* A contract attempts to get the coins */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_to != 0x0);                                // Prevent transfer to 0x0 address. Use burn() instead
        require(balanceOfField[_from] >= _value);                 // Check if the sender has enough
        require(balanceOfField[_to] + _value >= balanceOfField[_to]);  // Check for overflows
        require(_value <= allowanceField[_from][msg.sender]);     // Check allowance

        balanceOfField[_from] -= _value;                           // Subtract from the sender
        balanceOfField[_to] += _value;                             // Add the same to the recipient
        allowanceField[_from][msg.sender] -= _value;
        Transfer(_from, _to, _value);
        return true;
    }
}
