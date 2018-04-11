pragma solidity ^0.4.8;

import "./TokenERC20/StandardToken.sol";

contract TestToken is StandardToken{

  function () {
      throw;
  }

  string public name;
  uint8 public decimals;
  string public symbol;
  string public version = 'Tst0.2';

  function TestToken(
      uint256 _initialAmount,
      string _tokenName,
      uint8 _decimalUnits,
      string _tokenSymbol
      ) {
      balances[msg.sender] = _initialAmount;
      totalSupply = _initialAmount;
      name = _tokenName;
      decimals = _decimalUnits;
      symbol = _tokenSymbol;
  }

  function approveAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool success) {
      allowed[msg.sender][_spender] = _value;
      Approval(msg.sender, _spender, _value);

      if(!_spender.call(bytes4(bytes32(sha3("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraData)) { throw; }
      return true;
  }

  function mint(uint256 _value) returns (bool success) {
      totalSupply += _value;
      balances[msg.sender] += _value;
      return true;
  }

  function isAlive() returns (bool success){
    return true;
  }

}
