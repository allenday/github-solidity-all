pragma solidity 0.4.11;

import '../controller/Controller.sol';
import '../ownership/Ownable.sol';

contract UpgradeEvent {

  // states
  //  - verifying, initial state
  //  - controlling, after verifying, before complete
  //  - complete, after controlling
  enum EventState { Verifying, Controlling, Complete }
  EventState public state;

  // Terms
  address public nextController;
  address public oldController;
  address public council;

  // Params
  address pullAddr;
  address storageAddr;
  address nutzAddr;
  address powerAddr;
  uint256 maxPower;
  uint256 downtime;
  uint256 purchasePrice;
  uint256 salePrice;

  function UpgradeEvent(address _oldController, address _nextController) {
    state = EventState.Verifying;
    nextController = _nextController;
    oldController = _oldController;
    council = msg.sender;
  }

  modifier isState(EventState _state) {
    require(state == _state);
    _;
  }

  function tick() public {
    if (state == EventState.Verifying) {
      verify();
    } else if (state == EventState.Controlling) {
      complete();
    } else {
      throw;
    }
  }

  function verify() isState(EventState.Verifying) {
    // check old controller
    var old = Controller(oldController);
    require(old.admins(1) == address(this));
    require(old.paused() == true);
    // check next controller
    var next = Controller(nextController);
    require(next.admins(1) == address(this));
    require(next.paused() == true);
    // kill old one, and transfer ownership
    // transfer ownership of payments and storage to here
    pullAddr = old.pullAddr();
    storageAddr = old.storageAddr();
    nutzAddr = old.nutzAddr();
    powerAddr = old.powerAddr();
    maxPower = old.maxPower();
    downtime = old.downtime();
    purchasePrice = old.ceiling();
    salePrice = old.floor();
    // kill old controller, sending all ETH to new controller
    old.kill(nextController);
    // transfer ownership of Nutz/Power contracts to next controller
    Ownable(nutzAddr).transferOwnership(nextController);
    Ownable(powerAddr).transferOwnership(nextController);
    // transfer ownership of pull and storage to here
    Ownable(pullAddr).transferOwnership(address(this));
    Ownable(storageAddr).transferOwnership(address(this));
    state = EventState.Controlling;
  }

  function complete() isState(EventState.Controlling) {
    // if necessary, correct payment data
    // if necessary, correct storage data

    // transfer ownership of storage to next controller
    Ownable(storageAddr).transferOwnership(nextController);
    // if intended, transfer ownership of pull payment account
    // if pullPayment not transfered, kill, sending all eth to council multi-sig
    Ownable(pullAddr).transferOwnership(nextController);
    // resume next controller
    var next = Controller(nextController);
    if (maxPower > 0) {
      next.setMaxPower(maxPower);
    }
    next.setDowntime(downtime);
    next.moveFloor(salePrice);
    next.moveCeiling(purchasePrice);
    next.unpause();
    // remove access
    next.removeAdmin(address(this));
    // set state
    state = EventState.Complete;
  }

}
