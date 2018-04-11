pragma solidity ^0.4.7;

// ERC Token Standard #20 Interface
// https://github.com/ethereum/EIPs/issues/20
contract ERC20 {
    function totalSupply() constant returns (uint256 totalSupply);
    function balanceOf(address _owner) constant returns (uint256 balance);
    function transfer(address _to, uint256 _value) returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success);
    function approve(address _spender, uint256 _value) returns (bool success);
    function allowance(address _owner, address _spender) constant returns (uint256 remaining);
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

contract DigitalMaterai is ERC20 {
	string public constant name = "Digital Materai IDR";
    string public constant symbol = "DMI";
    uint8 public constant decimals = 18; 
    address public owner;
    uint256 _totalSupply; 
    mapping(address => uint256) balances;
	mapping(address => mapping (address => uint256)) allowed;
	mapping(bytes32 => mapping (address => uint256)) materai_record;

    modifier onlyOwner() {
        if (msg.sender != owner) {
            throw;
        }
        _;
    }

    function DigitalMaterai(uint initialSupply){
    	owner = msg.sender;
    	_totalSupply = initialSupply * 10 ** uint256(decimals); 
        balances[owner] = _totalSupply;
    }

    function totalSupply() constant returns (uint totalSupply){
    	return _totalSupply;
    }

    function balanceOf(address _owner) constant returns (uint balance){
    	return balances[_owner];
    }

    function _transfer(address _from, address _to, uint _value) internal {
        require(_to != 0x0);
        require(balances[_from] >= _value);
        require(balances[_to] + _value > balances[_to]);

        // Save this for an assertion in the future
        uint previousBalances = balances[_from] + balances[_to];
        
        balances[_from] -= _value;
        balances[_to] += _value;
        Transfer(_from, _to, _value);
        
        assert(balances[_from] + balances[_to] == previousBalances);
    }

    function transfer(address _to, uint _value) returns (bool success){
    	_transfer(msg.sender, _to, _value);
    }

    function transferFrom(address _from, address _to, uint _value) returns (bool success){
    	require(_value <= allowed[_from][msg.sender]);     // Check allowance
        allowed[_from][msg.sender] -= _value;
        _transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint _value) returns (bool success){
    	allowed[msg.sender][_spender] = _value;
        return true;
    }

    function allowance(address _owner, address _spender) constant returns (uint remaining){
    	return allowed[_owner][_spender];
    }

    event Transfer(address indexed _from, address indexed _to, uint _value);

    event Approval(address indexed _owner, address indexed _spender, uint _value);

    function mintToken(address target, uint256 mintedAmount) onlyOwner public {
        balances[target] += mintedAmount;
        _totalSupply += mintedAmount;
        Transfer(0, this, mintedAmount);
        Transfer(this, target, mintedAmount);
    }

    function stampDocument(bytes32 docHash, uint256 amount) public {
    	require(amount == 3000*10 ** uint256(decimals) || amount == 6000*10 ** uint256(decimals));
    	require(balances[msg.sender] >= amount);
    	require(materai_record[docHash][msg.sender] == 0);

    	balances[0x0] += amount;
    	balances[msg.sender] -= amount;
    	_totalSupply -= amount;
    	materai_record[docHash][msg.sender] = amount;
    }

    function readStamped(bytes32 docHash) constant public returns (uint){
    	return materai_record[docHash][msg.sender];
    }
}