pragma solidity ^0.4.16;

import "utils/HumanStandardToken.sol";

contract AnythingToken is HumanStandardToken {
  function AnythingToken(uint256 _initialBalance) public {
    name = "Anything Token";
    decimals = 18;
    symbol = "ANY";
    initialBalance = _initialBalance;
  }

  modifier assignBalance(address _to) {
    if (!hasTransfered[_to]) {
      balances[_to] = initialBalance;
      hasTransfered[_to] = true;
    }
    _;
  }

  function transfer(address _to, uint256 _value) public assignBalance(msg.sender) returns (bool success) {
    return super.transfer(_to, _value);
  }

  function approve(address _spender, uint256 _value) public assignBalance(msg.sender) returns (bool success) {
    return super.approve(_spender, _value);
  }

  function balanceOf(address _owner) public constant returns (uint256 balance) {
    if (hasTransfered[_owner])
      balance = super.balanceOf(_owner);
    else
      balance = initialBalance;
  }

  uint256 public initialBalance = 100;
  mapping(address => bool) public hasTransfered;
}
