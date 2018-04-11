pragma solidity ^0.4.18;

import "./Owned.sol";
import "./TokenEIP20.sol";
import "./TokenNotifier.sol";
import "./SafeMathLib.sol";

contract SimpleToken is Owned, TokenEIP20 {
    using SafeMathLib for uint256;
    
    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;
    
    string public name;
    string public symbol;

    uint256 public decimals;
    uint256 public totalSupply;

    function SimpleToken(string _name, string _symbol, uint256 _decimals, uint256 _totalSupply) public {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        totalSupply = decimals > 0 ? _totalSupply * 10**decimals : _totalSupply;
        balances[owner] = totalSupply;
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        if (balances[msg.sender] < _value) {
            return false;
        }
        balances[msg.sender] = balances[msg.sender].sub(_value);
        assert(balances[msg.sender] >= 0);
        balances[_to] = balances[_to].add(_value);
        assert(balances[_to] <= totalSupply);
        Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        if (balances[_from] < _value || allowed[_from][msg.sender] < _value) {
            return false;
        }
        balances[_from] = balances[_from].sub(_value);
        assert(balances[_from] >= 0);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        assert(balances[_to] <= totalSupply);        
        Transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function approveAndCall(address _spender, uint256 _value, bytes _extraData) public returns (bool success) {
        if (!approve(_spender, _value)) {
            return false;
        }
        TokenNotifier(_spender).receiveApproval(msg.sender, _value, this, _extraData);
        return true;
    }

    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }

    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }
}