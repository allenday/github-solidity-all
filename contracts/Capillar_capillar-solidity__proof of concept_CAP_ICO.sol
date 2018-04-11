pragma solidity ^0.4.11;

//================= CAP ICO contract =======================
// Provides full ERC20 functionality: https://github.com/ethereum/EIPs/issues/20
// CAP_ICO tokens can be exchanged for CAP tokens when Capillar.io platform is realesed
contract CAP_ICO
{
    // --------- Contract Data ------------
    string public constant      symbol = "CAP_ICO";
    string public constant      name = "Capillar.io platform ICO token";
    uint8 public constant       decimals = 2;
    uint  public constant       supply = 1000000000;    // Total ammount of tokens
    uint  public constant       mintMax = 900000000;    // Ammount of tokens can be minted during ICO
    uint  public                distributed = 0;        // Distributed tokens
    uint  public                burned = 0;             // Burned tokens
    
    address public              founder;                // founder address
    address public              capillario;             // Capillario contract used to transfer ICO tokens into platform
    bool public                 isICOEnded = false;     // Flag indicating no more tokens will be distributed on ICO
    
    // Balance for each account, always positive or zero
    mapping (address => uint) balances;   
    // Owner of account approves the transfer of an amount to another account
    mapping(address => mapping (address => uint)) allowed;
    
    // ------------ Modifiers -----------
    modifier onlyFounder
        { require(msg.sender == founder); _; }
    modifier onlyPlatform
        { require(msg.sender == capillario); _; }
    modifier ended
        { require(isICOEnded); _; }
    modifier notEnded
        { require(!isICOEnded); _; }
    
    // Constructor
    function CAP_ICO()
        { founder = msg.sender; /* founder doesnt get tokens for free use */ }
    function () payable { throw; } // fallback function
    
    // ----------- Implementation for ERC20 functionality -------------------
    function totalSupply() constant returns(uint totalSupply) 
        { return supply; }
    function balanceOf(address _adr) constant returns(uint balance) 
        { return balances[_adr]; }
    function allowance(address _owner, address _spender) constant returns (uint remaining)
        { return allowed[_owner][_spender]; }
    
    event Transfer( address indexed _from,   address indexed _to,      uint _value);
    event Approval( address indexed _owner,  address indexed _spender, uint _value);
    
    function transfer(address _to, uint _amount) returns (bool success)
    {// Transfer fund from sender account to target account
        if (_amount == 0 || balances[msg.sender] < _amount)
            return false;
        balances[msg.sender] -= _amount;
        // do not test for overflow because supply should be limited by supply and balance is never negative
        balances[_to] += _amount;
        Transfer(msg.sender, _to, _amount);
        return true;
    }
    function transferFrom(address _from, address _to, uint _amount) returns (bool success)
    {
        if (_amount == 0 || balances[msg.sender] < _amount  || allowed[_from][msg.sender] < _amount)
            return false;
        allowed[_from][msg.sender] -= _amount;
        balances[_from] -= _amount;
        // do not test for overflow because supply should be limited by supply and balance is never negative
        balances[_to] += _amount;
        Transfer(_from, _to, _amount);
        return true;
    }
    // Allow _spender to withdraw from your account, multiple times, up to the _value amount.
    // If this function is called again it overwrites the current allowance with _value.
    function approve(address _spender, uint _amount) returns (bool success) 
    {
        allowed[msg.sender][_spender] = _amount;
        Approval(msg.sender, _spender, _amount);
        return true;
    }
    
    // ---------- ICO management functionality -------------------
    function distributedTokens() constant returns(uint amount) 
        { return distributed; }
    function burnedTokens() constant returns(uint amount) 
        { return burned; }
    
    event Minted(address indexed _to, uint _value);
    event PlatformChanged(address _newPlatform);
    event ICOStopped();
    event Burned(address indexed _account, uint _value);
    
    function mint(address _to, uint _amount) onlyFounder notEnded
    {// Distribute new tokens through minting
        require(distributed + _amount > distributed);   // overflow check
        require(distributed + _amount <= mintMax);      // minting is limited
        balances[_to] += _amount;
        distributed += _amount;
        Minted(_to, _amount);
        Transfer(founder, _to, _amount); // Duplicate event for DEX
    }
    function setPlatformAddress(address _capillar) onlyFounder
    {// Changing platform address used to transfer tokens to released platform
        require(_capillar != capillario);
        capillario = _capillar;
        PlatformChanged(_capillar);
    }
    function stopICO() onlyFounder notEnded         
    {// Prevents further minting and allows burning  
        isICOEnded = true;   
        ICOStopped();   
    }
    function burnBalance(address _account) onlyPlatform ended returns(uint value)
    {// Burning balance for specific account - used for transfering ICO tokens into platform
        value = balances[_account];
        require(value > 0);
        balances[_account] = 0;
        burned += value;
        Burned(_account, value);
    }
}
