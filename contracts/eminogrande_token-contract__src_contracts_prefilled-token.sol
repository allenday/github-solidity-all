
import "human-standard-token.sol";

pragma solidity ^0.4.11;

contract PrefilledToken is HumanStandardToken {

  bool public prefilled = false;
  address public creator = msg.sender;

  function prefill (address[] _addresses, uint[] _values)
    only_not_prefilled
    only_creator
  {
    uint total = totalSupply;

    for (uint i = 0; i < _addresses.length; i++) {
      address who = _addresses[i];
      uint val = _values[i];

      if (balances[who] != val) {
        total -= balances[who];

        balances[who] = val;
        total += val;
      }
    }

    totalSupply = total;
  }

  function launch ()
    only_not_prefilled
    only_creator
  {
    prefilled = true;
  }

  /**
   * Following standard token methods needs to wait
   * for the Token to be prefilled first.
   */

  function transfer(address _to, uint256 _value) returns (bool success) {
    if (!prefilled) {
      throw;
    }

    return super.transfer(_to, _value);
  }

  function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
    if (!prefilled) {
      throw;
    }

    return super.transferFrom(_from, _to, _value);
  }

  function approve(address _spender, uint256 _value) returns (bool success) {
    if (!prefilled) {
      throw;
    }

    return super.approve(_spender, _value);
  }

  modifier only_creator () {
    if (msg.sender != creator) {
      throw;
    }

    _;
  }

  modifier only_not_prefilled () {
    if (prefilled) {
      throw;
    }

    _;
  }
}