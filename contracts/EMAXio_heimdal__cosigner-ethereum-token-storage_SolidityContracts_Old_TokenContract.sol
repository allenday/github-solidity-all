pragma solidity ^0.4.15;

contract TokenContract {
  address owner;

  string public name;
  string public symbol;
  uint8 public decimals;

  mapping(address => uint) balances;
  uint totalBalance;

  mapping(address => mapping(address => uint)) allowances;

  event Transfer(address indexed _from, address indexed _to, uint256 _value);
  event TransferOnBehalf(address indexed _sender, address indexed _from, address indexed _to, uint256 _value);
  event Approval(address indexed _owner, address indexed _spender, uint256 _value);

  function getOwner() constant returns(address) {
    return owner;
  }

  function allowance(address _owner, address _spender) constant returns(uint256 remaining) {
    return allowances[_owner][_spender];
  }

  function balanceOf(address _owner) constant returns(uint256 balance) {
    return balances[_owner];
  }

  function totalSupply() constant returns(uint256 supply) {
    return totalBalance;
  }

  function TokenContract(address _owner, string _name, string _symbol, uint8 _decimals) {
    owner = _owner;
    name = _name;
    symbol = _symbol;
    decimals = _decimals;
  }

  function updateOwner(address _owner) {
    if (msg.sender == owner) {
      owner = _owner;
    }
  }

  function approve(address _spender, uint256 _value) returns(bool success) {
    allowances[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

  function transfer(address _to, uint256 _value) returns(bool success) {
    if (_to == owner) {
      revert();
    }

    if (balances[msg.sender] >= _value || msg.sender == owner) {
      if (msg.sender != owner) {
        balances[msg.sender] -= _value;
      } else {
        totalBalance += _value;
      }
      balances[_to] += _value;
      Transfer(msg.sender, _to, _value);
      return true;
    } else {
      revert();
    }
  }

  function transferFrom(address _from, address _to, uint256 _value) returns(bool success) {
    if (_to == owner) {
      revert();
    }

    if (balances[_from] >= _value && allowances[_from][msg.sender] >= _value) {
      allowances[_from][msg.sender] -= _value;
      balances[_from] -= _value;
      balances[_to] += _value;
      Transfer(_from, _to, _value);
      TransferOnBehalf(msg.sender, _from, _to, _value);
      return true;
    } else {
      revert();
    }
  }

  function transferOnBehalf(address _from, address _to, uint256 _value) returns(bool success) {
    if (_to == owner && balances[msg.sender] >= _value) {
      balances[msg.sender] -= _value;
      totalBalance -= _value;
      Transfer(_from, _to, _value);
      TransferOnBehalf(msg.sender, _from, _to, _value);
      TokenAdminContract parent = TokenAdminContract(owner);
      if (parent.deposit(msg.sender, _from, _value)) {
        return true;
      } else {
        revert();
      }
    } else {
      if (balances[msg.sender] >= _value) {
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        Transfer(_from, _to, _value);
        TransferOnBehalf(msg.sender, _from, _to, _value);
        return true;
      } else {
        revert();
      }
    }
  }
}
