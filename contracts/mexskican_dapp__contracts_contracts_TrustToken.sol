pragma solidity ^0.4.8;

contract TrustToken {
    // ERC20 token identifiers
    string public constant symbol = "TC";
    string public constant name = "Trust Coin";
    uint8 public constant decimals = 0;
    // Owner of the contract
    address public owner;
    // Total supply of tokens
    uint256 _totalSupply = 1000000;
    // Ledger of the balance of the account
    mapping (address => uint256) balances;
    // Owner of account approuves the transfert of an account to another account
    mapping (address => mapping (address => uint256)) allowed;
    // Mapping of the users registered names
    mapping (address => string) public names;
    // Mapping of the address
    mapping (uint => address) public members;
    // Count of registered users
    uint public memberCount = 0;

    // Modifier
    // Check if the address is registered
    modifier isRegistered { require(keccak256(names[msg.sender]) == keccak256("")); _;}

    // Events
    // Triggered when tokens are transferred
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    // Triggered whenever approve(address _spender, uint256 _value) is called.
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    // Constructor
    function TrustToken() public {
        owner = msg.sender;
        balances[owner] = _totalSupply;
    }
   
    // Add a new user (address in the ledger)
    function add(string _name) public returns (bool success) {
        if(keccak256(names[msg.sender]) != keccak256("")){
            return false;
        }
        if(keccak256(_name) == keccak256("")){
            return false;
        }
        names[msg.sender] = _name;
        members[memberCount] = msg.sender;
        memberCount++;
        return true;
    }

    // Transfert the amont _value from the address calling the function to address _to
    function transfer(address _to, uint256 _value) public returns (bool success) {
       if (keccak256(names[_to]) == keccak256("")) {
            return false;
       }
        // Check if the value is autorized
        if (balances[msg.sender] >= _value && _value > 0) {
            // Decrease the sender balance
            balances[msg.sender] -= _value;
            // Increase the sender balance
            balances[_to] += _value;
            // Trigger the Transfer event
            Transfer(msg.sender, _to, _value);
            return true;
        } else { return false; }
    }

    // Return the total supply of coin
    function totalSupply() public constant returns (uint256 resultSupply) {
        resultSupply = _totalSupply;
    }

    // Transfert from an allowed address
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
       if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && balances[_to] + _value > balances[_to]) {
            balances[_to] += _value;
            balances[_from] -= _value;
            allowed[_from][msg.sender] -= _value;
            Transfer(_from, _to, _value);
            return true;
        } else { return false; }
    }

    // Return the balance of an account
    function balanceOf(address _owner) public constant returns (uint256 balance) {
        return balances[_owner];
    }

    // Autorize the address _spender to transfer from the account msg.sender
    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    // Return the amont of allowance
    function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }
}