pragma solidity 0.4.11;

import "../satelites/Storage.sol";

contract StorageEnabled {

  // satelite contract addresses
  address public storageAddr;

  function StorageEnabled(address _storageAddr) {
    storageAddr = _storageAddr;
  }


  // ############################################
  // ########### NUTZ FUNCTIONS  ################
  // ############################################


  // all Nutz balances
  function babzBalanceOf(address _owner) constant returns (uint256) {
    return Storage(storageAddr).getBal('Nutz', _owner);
  }
  function _setBabzBalanceOf(address _owner, uint256 _newValue) internal {
    Storage(storageAddr).setBal('Nutz', _owner, _newValue);
  }
  // active supply - sum of balances above
  function activeSupply() constant returns (uint256) {
    return Storage(storageAddr).getUInt('Nutz', 'activeSupply');
  }
  function _setActiveSupply(uint256 _newActiveSupply) internal {
    Storage(storageAddr).setUInt('Nutz', 'activeSupply', _newActiveSupply);
  }
  // burn pool - inactive supply
  function burnPool() constant returns (uint256) {
    return Storage(storageAddr).getUInt('Nutz', 'burnPool');
  }
  function _setBurnPool(uint256 _newBurnPool) internal {
    Storage(storageAddr).setUInt('Nutz', 'burnPool', _newBurnPool);
  }
  // power pool - inactive supply
  function powerPool() constant returns (uint256) {
    return Storage(storageAddr).getUInt('Nutz', 'powerPool');
  }
  function _setPowerPool(uint256 _newPowerPool) internal {
    Storage(storageAddr).setUInt('Nutz', 'powerPool', _newPowerPool);
  }





  // ############################################
  // ########### POWER   FUNCTIONS  #############
  // ############################################

  // all power balances
  function powerBalanceOf(address _owner) constant returns (uint256) {
    return Storage(storageAddr).getBal('Power', _owner);
  }

  function _setPowerBalanceOf(address _owner, uint256 _newValue) internal {
    Storage(storageAddr).setBal('Power', _owner, _newValue);
  }

  function outstandingPower() constant returns (uint256) {
    return Storage(storageAddr).getUInt('Power', 'outstandingPower');
  }

  function _setOutstandingPower(uint256 _newOutstandingPower) internal {
    Storage(storageAddr).setUInt('Power', 'outstandingPower', _newOutstandingPower);
  }

  function authorizedPower() constant returns (uint256) {
    return Storage(storageAddr).getUInt('Power', 'authorizedPower');
  }

  function _setAuthorizedPower(uint256 _newAuthorizedPower) internal {
    Storage(storageAddr).setUInt('Power', 'authorizedPower', _newAuthorizedPower);
  }


  function downs(address _user) constant public returns (uint256 total, uint256 left, uint256 start) {
    uint256 rawBytes = Storage(storageAddr).getBal('PowerDown', _user);
    start = uint64(rawBytes);
    left = uint96(rawBytes >> (64));
    total = uint96(rawBytes >> (96 + 64));
    return;
  }

  function _setDownRequest(address _holder, uint256 total, uint256 left, uint256 start) internal {
    uint256 result = uint64(start) + (left << 64) + (total << (96 + 64));
    Storage(storageAddr).setBal('PowerDown', _holder, result);
  }

}
