pragma solidity 0.4.11;

import "./PowerEnabled.sol";

contract Controller is PowerEnabled {

  function Controller(address _powerAddr, address _pullAddr, address _nutzAddr, address _storageAddr) 
    PowerEnabled(_powerAddr, _pullAddr, _nutzAddr, _storageAddr) {
  }

  function setContracts(address _storageAddr, address _nutzAddr, address _powerAddr, address _pullAddr) public onlyAdmins whenPaused {
    storageAddr = _storageAddr;
    nutzAddr = _nutzAddr;
    powerAddr = _powerAddr;
    pullAddr = _pullAddr;
  }

  function changeDailyLimit(uint256 _dailyLimit) public onlyAdmins {
    PullPayment(pullAddr).changeDailyLimit(_dailyLimit);
  }

  function kill(address _newController) public onlyAdmins whenPaused {
    if (powerAddr != address(0)) { Ownable(powerAddr).transferOwnership(msg.sender); }
    if (pullAddr != address(0)) { Ownable(pullAddr).transferOwnership(msg.sender); }
    if (nutzAddr != address(0)) { Ownable(nutzAddr).transferOwnership(msg.sender); }
    if (storageAddr != address(0)) { Ownable(storageAddr).transferOwnership(msg.sender); }
    selfdestruct(_newController);
  }

}
