pragma solidity ^0.4.18;

contract ReentryProtected {

  // The reentry protection state mutex.
  bool private reentrancy_lock = false;
  
  // Sets and resets mutex in order to block function reentry
  modifier preventReentry() {
    require(!reentrancy_lock);
    reentrancy_lock = true;
    _;
    delete reentrancy_lock;
  }

  // Blocks function entry if mutex is set
  modifier noReentry() {
    require(!reentrancy_lock);
    _;
  }
}
