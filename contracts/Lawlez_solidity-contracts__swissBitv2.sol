pragma solidity ^0.4.18;

contract SwissBit {
    /* This creates an array with all balances */
    mapping (address => uint256) public balanceOf;

/**
 * See https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20_Token {
    // Triggered when tokens are transferred.
    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    // Triggered whenever approve(address _spender, uint256 _value) is called.
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    // Get the total token supply
    function totalSupply() constant returns (uint256 totalSupply);
    
    // Get the account balance of another account with address _owner
    function balanceOf(address _owner) constant returns (uint256 balance);
    
    // Send _value amount of tokens to address _to
    function transfer(address _to, uint256 _value) returns (bool success);
    
    // Send _value amount of tokens from address _from to address _to
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success);
    
    // Allow _spender to withdraw from your account, multiple times, up to the _value amount. If this function is called again it overwrites the current allowance with _value.
    function approve(address _spender, uint256 _value) returns (bool success);
    
    // Returns the amount which _spender is still allowed to withdraw from _owner
    function allowance(address _owner, address _spender) constant returns (uint256 remaining);
}

contract SwissBit is ERC20_Token {
    mapping (address => uint256) public balances;
    mapping (address => mapping (address => uint256)) public allowance;

    uint256 supply;
    
    /**
     * Prevent an account from behing 0x0
     * @param addr Address to check
     */
    modifier No0x(address addr) { 
        if (addr == 0x0) revert();
        _; 
    }

    /**
     * A modifer to check validity of a balance for a transfer
     * from an account to another.
     * @param from  [description]
     * @param to    [description]
     * @param value [description]
     */
    modifier ValidBalance(address from, address to, uint256 value) { 
        if (balances[from] < value) revert();                 // Check if the sender has enough
        if (balances[to] + value < balances[to]) revert();  // Check for overflows
        _; 
    }
    
    /**
     * Returns the total amount of tokens
     * @return total amount
     */
    function totalSupply() constant returns(uint256 totalSupply) {
        return supply;
    }

    /**
     * Returns The balance of a given account
     * @param addr Address of the account
     * @return Balance
     */
    function balanceOf(address addr) constant returns(uint256 balance) {
        return balances[addr];
    }
    
    /**
     * Returns the amount which _spender is still allowed to withdraw from _owner
     */
    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
        return allowance[_owner][_spender]; 
    }


    /**
     * Constructor of SwissBit
     * @param _totalSupply Total amount of tokens initially issued
     */
    function SwissBit (uint256 _totalSupply) {
        supply = _totalSupply;
        balances[msg.sender] = _totalSupply;
    }

    /**
     * Send coins
     * @param _to       The recipient of tokens
     * @param _value    Amount of tokens to send 
     */
     function transfer(address _to, uint256 _value) No0x(_to) ValidBalance(msg.sender, _to, _value) 
     returns (bool success) {                        
        balances[msg.sender] -= _value;                     // Subtract from the sender
        balances[_to] += _value;                            // Add the same to the recipient
        Transfer(msg.sender, _to, _value);                   // Notify anyone listening that this transfer took place
        return true;
    }

    /**
     * Allow another contract to spend some tokens in your behalf
     * @param _spender  Account that can take some of your tokens
     * @param _value    Max amount of tokens the _spender account can take
     * @return {return} Return true if the action succeeded
     */
    function approve(address _spender, uint256 _value) returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }  

    /**
     * A contract attempts to get the coins
     * @param _from     Address holding the tokens to transfer
     * @param _to       Account to send the coins to
     * @param _value    How many tokens     
     * @return {bool}   Whether the call was successful
     */
    function transferFrom(address _from, address _to, uint256 _value) No0x (_to) ValidBalance(_from, _to, _value)
    returns (bool success) {
        if (_value > allowance[_from][msg.sender]) revert();     // Check allowance
        balances[_from] -= _value;                           // Subtract from the sender
        balances[_to] += _value;                             // Add the same to the recipient
        allowance[_from][msg.sender] -= _value;
        Transfer(_from, _to, _value);
        return true;
    }
}
