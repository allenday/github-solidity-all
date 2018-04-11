pragma solidity ^0.4.10;

contract owned {
    address public owner;

    function owned() {
        owner = msg.sender;
    }

    modifier onlyOwner {
        if (msg.sender != owner) throw;
        _;
    }

    /* Change the owner of the contract */
    function transferOwnership(address newOwner) onlyOwner {
        owner = newOwner;
    }
}
contract Nerdearla is owned {

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

  address public owner;

  mapping(address => uint) balances;

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

  /* Allow minting onyl to owner */
  function mintToken(address target, uint256 mintedAmount) onlyOwner {
      balanceOf[target] += mintedAmount;
      totalSupply += mintedAmount;
      Transfer(0, owner, mintedAmount);
      Transfer(owner, target, mintedAmount);
  }

  event Transfer(address indexed from, address indexed to, uint value);

}
