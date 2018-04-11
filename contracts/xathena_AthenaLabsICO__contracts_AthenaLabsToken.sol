pragma solidity ^0.4.4;

import 'zeppelin-solidity/contracts/token/MintableToken.sol';
import 'zeppelin-solidity/contracts/token/BurnableToken.sol';
import 'zeppelin-solidity/contracts/lifecycle/Pausable.sol';

contract AthenaLabsToken is MintableToken, BurnableToken {

  string public name = "ATHENA";
  string public symbol = "ATN";
  uint256 public decimals = 18;
  bool public isFinalized = false;

  uint256 public maxFinalizationTime;

  function setMaxFinalizationTime(uint256 _maxFinalizationTime) onlyOwner public {
    maxFinalizationTime = _maxFinalizationTime;
  }

  // only owner (ICO contract) can operate token, when paused
  // token will be unpaused at the end of ICO
  function transfer(address _to, uint256 _value) public whenFinalizedOrOnlyOwner returns (bool) {
    return super.transfer(_to, _value);
  }

  function transferFrom(address _from, address _to, uint256 _value) public whenFinalizedOrOnlyOwner returns (bool) {
    return super.transferFrom(_from, _to, _value);
  }

  function approve(address _spender, uint256 _value) public whenFinalizedOrOnlyOwner returns (bool) {
    return super.approve(_spender, _value);
  }

  function increaseApproval(address _spender, uint _addedValue) public whenFinalizedOrOnlyOwner returns (bool success) {
    return super.increaseApproval(_spender, _addedValue);
  }

  function decreaseApproval(address _spender, uint _subtractedValue) public whenFinalizedOrOnlyOwner returns (bool success) {
    return super.decreaseApproval(_spender, _subtractedValue);
  }

  function burn(uint256 _value) public whenFinalizedOrOnlyOwner {
    return super.burn(_value);
  }

  modifier whenFinalizedOrOnlyOwner() {
    require(isFinalized || (msg.sender == owner));
    _;
  }

  event Finalized();

  /**
   *
   */
  function finalize() public {
    require((msg.sender == owner) || (now >= maxFinalizationTime));
    require(!isFinalized);
    Finalized();
    isFinalized = true;
  }

  function finishMinting() public onlyOwner returns (bool) {
    mintingFinished = true;
    MintFinished();
    return true;
  }
}
