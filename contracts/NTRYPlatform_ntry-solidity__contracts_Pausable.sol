/**
 *  Pausable.sol v1.0.0
 * 
 *  Bilal Arif - https://twitter.com/furusiyya_
 *  Notary Platform
 */

pragma solidity ^0.4.16;

import "./Ownable.sol";

/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is Ownable {
  
  event Pause(bool indexed state);

  bool private paused = false;

  /**
   * @dev Modifier to make a function callable only when the contract is not paused.
   */
  modifier whenNotPaused() {
    require(!paused);
    _;
  }

  /**
   * @dev Modifier to make a function callable only when the contract is paused.
   */
  modifier whenPaused() {
    require(paused);
    _;
  }

  /**
   * @dev return the current state of contract
   */
  function Paused() external constant returns(bool){ return paused; }

  /**
   * @dev called by the owner to pause or unpause, triggers stopped state
   * on first call and returns to normal state on second call
   */
  function tweakState() external onlyOwner {
    paused = !paused;
    Pause(paused);
  }

}