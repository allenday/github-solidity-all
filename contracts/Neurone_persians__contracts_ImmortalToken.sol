pragma solidity ^0.4.18;

import "./Owned.sol";
import "./SafeMath.sol";
import "./TokenERC20.sol";
import "./TokenNotifier.sol";

contract ImmortalToken is Owned, SafeMath, TokenERC20 {

    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;
    
    uint8 public constant decimals = 0;
    uint8 public constant totalSupply = 100;
    string public constant name = "Immortal";
    string public constant symbol = "IMT";
    string public constant version = "1.0.1";

    function transfer(address _to, uint256 _value) public returns (bool success) {
        if (balances[msg.sender] < _value) {
            return false;
        }
        balances[msg.sender] = safeSub(balances[msg.sender], _value);
        assert(balances[msg.sender] >= 0);
        balances[_to] = safeAdd(balances[_to], _value);
        assert(balances[_to] <= totalSupply);
        Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        if (balances[_from] < _value || allowed[_from][msg.sender] < _value) {
            return false;
        }
        balances[_from] = safeSub(balances[_from], _value);
        assert(balances[_from] >= 0);
        allowed[_from][msg.sender] = safeSub(allowed[_from][msg.sender], _value);
        balances[_to] = safeAdd(balances[_to], _value);
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