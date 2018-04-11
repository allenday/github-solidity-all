pragma solidity ^0.4.11;


import "dp_math.sol";


// Token standard API
// https://github.com/ethereum/EIPs/issues/20
contract ERC20 {
  function totalSupply() constant returns (uint supply);

  function balanceOf(address who) constant returns (uint value);

  function allowance(address owner, address spender) constant returns (uint _allowance);

  function transfer(address to, uint value) returns (bool ok);

  function transferFrom(address from, address to, uint value) returns (bool ok);

  function approve(address spender, uint value) returns (bool ok);

  event Transfer(address indexed from, address indexed to, uint value);

  event Approval(address indexed owner, address indexed spender, uint value);
}


contract APaymentToken is ERC20, DPMath {
  uint256                                            _supply;
  mapping (address => uint256)                       _balances;
  mapping (address => mapping (address => uint256))  _approvals;

  string public constant name = "aPayment Token";

  string public constant symbol = "APT";

  function APaymentToken(uint256 supply) {
    _balances[msg.sender] = supply;
    _supply = supply;
  }

  function totalSupply() constant returns (uint256) {
    return _supply;
  }

  function balanceOf(address src) constant returns (uint256) {
    return _balances[src];
  }

  function allowance(address src, address guy) constant returns (uint256) {
    return _approvals[src][guy];
  }

  function transferWithMessageAndRequestAddress(address dst, uint amount, address requestAdr, bytes message) returns (bool) {
    return transfer(dst, amount);
  }

  function transferWithMessage(address dst, uint amount, bytes message) returns (bool) {
    return transfer(dst, amount);
  }

  function transfer(address dst, uint amount) returns (bool) {
    assert(_balances[msg.sender] >= amount);

    _balances[msg.sender] = sub(_balances[msg.sender], amount);
    _balances[dst] = add(_balances[dst], amount);

    Transfer(msg.sender, dst, amount);

    return true;
  }

  function transferFrom(address src, address dst, uint amount) returns (bool) {
    assert(_balances[src] >= amount);
    assert(_approvals[src][msg.sender] >= amount);

    _approvals[src][msg.sender] = sub(_approvals[src][msg.sender], amount);
    _balances[src] = sub(_balances[src], amount);
    _balances[dst] = add(_balances[dst], amount);

    Transfer(src, dst, amount);

    return true;
  }

  function approve(address guy, uint256 amount) returns (bool) {
    _approvals[msg.sender][guy] = amount;

    Approval(msg.sender, guy, amount);

    return true;
  }
}