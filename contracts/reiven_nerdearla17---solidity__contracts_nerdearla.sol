pragma solidity ^0.4.10;


contract Nerdearla {

  function safeSub(uint a, uint b) internal returns (uint) {
    assert(b <= a);
    return a - b;
  }

  function safeAdd(uint a, uint b) internal returns (uint) {
    uint c = a + b;
    assert(c>=a && c>=b);
    return c;
  }

  string public constant symbol = "NERD";
  string public constant name = "Nerdearla";
  uint8 public constant decimals = 18;
  uint256 _totalSupply = 21000000;

  /* Owner of this contract */
  address public owner;

  mapping(address => uint) balances;

  /* Set the owner and set the totalSupply */
  function Nerdearla() {
      owner = msg.sender;
      balances[owner] = _totalSupply;
  }

  function totalSupply() constant returns (uint256 totalSupply) {
      totalSupply = _totalSupply;
  }

  function transfer(address _to, uint _value) returns (bool success) {
    balances[msg.sender] = safeSub(balances[msg.sender], _value);
    balances[_to] = safeAdd(balances[_to], _value);
    Transfer(msg.sender, _to, _value);
    return true;
  }

  function balanceOf(address _owner) constant returns (uint balance) {
    return balances[_owner];
  }

  event Transfer(address indexed from, address indexed to, uint value);

}
