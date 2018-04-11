pragma solidity ^0.4.18;

import "../registry/DSPRegistry.sol";
import "./SecurityDepositAware.sol";


contract DSPRegistrar is DSPTypeAware, SecurityDepositAware {

  // EVENTS

  event DSPRegistered(address indexed dspAddress);
  event DSPUnregistered(address indexed dspAddress);
  event DSPParametersChanged(address indexed dspAddress);

  // PUBLIC FUNCTIONS

  //@dev Register organisation as DSP
  //@param dspAddress address of wallet to register
  function registerDsp(address dspAddress, DSPType dspType, bytes32[5] url) public {
    receiveSecurityDeposit(dspAddress);
    dspRegistry.register(dspAddress, dspType, url, msg.sender);
    DSPRegistered(dspAddress);
  }

  //@dev Unregister DSP and return unused deposit
  //@param Address of DSP to be unregistered
  function unregisterDsp(address dspAddress) public {
    returnDeposit(dspAddress, securityDepositRegistry);
    dspRegistry.unregister(dspAddress, msg.sender);
    DSPUnregistered(dspAddress);
  }

  //@dev Change url of DSP
  //@param address of DSP to change
  //@param new url
  function updateUrl(address key, bytes32[5] url) public {
    dspRegistry.updateUrl(key, url, msg.sender);
    DSPParametersChanged(key);
  }

  //@dev Transfer ownership of this DSP record
  //@param address of DSP
  //@param address of new owner
  function transferDSPRecord(address key, address newOwner) public {
    dspRegistry.transfer(key, newOwner, msg.sender);
  }

  //@dev Retrieve information about registered DSP
  //@return Address of registered DSP and time when registered
  function findDsp(address addr)
    public
    view
    returns (address dspAddress, DSPType dspType, bytes32[5] url, uint256[2] karma, address recordOwner)
  {
    return dspRegistry.getDSP(addr);
  }

  //@dev Check if DSP registered
  function isDspRegistered(address key) public view returns (bool) {
    return dspRegistry.isRegistered(key);
  }

  // FIELDS

  DSPRegistry public dspRegistry;
}
