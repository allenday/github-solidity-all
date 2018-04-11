pragma solidity ^0.4.15;

import './StandardToken.sol';
import '../lifecycle/Pausable.sol';

/**
 * @title Pausable token
 *
 * @dev StandardToken modified with pausable transfers.
 **/

contract PausableToken is StandardToken, Pausable {
  /**
   * @dev modifier to allow actions only when the contract is not paused or
   * the sender is the owner of the contract
   */
  modifier whenNotPausedOrOwner() {
    require(msg.sender == owner || !paused);
    _;
  }

  function transfer(address _to, uint256 _value) public whenNotPausedOrOwner returns (bool) {
    return super.transfer(_to, _value);
  }

  function transferFrom(address _from, address _to, uint256 _value) public whenNotPausedOrOwner returns (bool) {
    return super.transferFrom(_from, _to, _value);
  }

  function approve(address _spender, uint256 _value) public whenNotPausedOrOwner returns (bool) {
    return super.approve(_spender, _value);
  }

  function increaseApproval(address _spender, uint _addedValue) public whenNotPausedOrOwner returns (bool success) {
    return super.increaseApproval(_spender, _addedValue);
  }

  function decreaseApproval(address _spender, uint _subtractedValue) public whenNotPausedOrOwner returns (bool success) {
    return super.decreaseApproval(_spender, _subtractedValue);
  }
}