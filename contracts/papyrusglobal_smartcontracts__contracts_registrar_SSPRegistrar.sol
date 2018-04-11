pragma solidity ^0.4.18;

import "../registry/SSPRegistry.sol";
import "./SecurityDepositAware.sol";


contract SSPRegistrar is SSPTypeAware, SecurityDepositAware {

  // EVENTS

  event SSPRegistered(address indexed sspAddress);
  event SSPUnregistered(address indexed sspAddress);
  event SSPParametersChanged(address indexed sspAddress);

  // PUBLIC FUNCTIONS

  //@dev Register organisation as SSP
  //@param sspAddress address of wallet to register
  function registerSsp(address sspAddress, SSPType sspType, uint16 publisherFee) public {
    receiveSecurityDeposit(sspAddress);
    sspRegistry.register(sspAddress, sspType, publisherFee, msg.sender);
    SSPRegistered(sspAddress);
  }

  //@dev Unregister SSP and return unused deposit
  //@param Address of SSP to be unregistered
  function unregisterSsp(address sspAddress) public {
    returnDeposit(sspAddress, securityDepositRegistry);
    sspRegistry.unregister(sspAddress, msg.sender);
    SSPUnregistered(sspAddress);
  }

  //@dev Change publisher fee of SSP
  //@param address of SSP to change
  //@param new publisher fee
  function updatePublisherFee(address key, uint16 newFee) public {
    sspRegistry.updatePublisherFee(key, newFee, msg.sender);
    SSPParametersChanged(key);
  }

  //@dev transfer ownership of this SSP record
  //@param address of SSP
  //@param address of new owner
  function transferSSPRecord(address key, address newOwner) public {
    sspRegistry.transfer(key, newOwner, msg.sender);
  }

  //@dev Retrieve information about registered SSP
  //@return Address of registered SSP and time when registered
  function findSsp(address _sspAddress)
    public
    view
    returns (address sspAddress, SSPType sspType, uint16 publisherFee, uint256[2] karma, address recordOwner)
  {
    return sspRegistry.getSSP(_sspAddress);
  }

  //@dev check if SSP registered
  function isSspRegistered(address key) public view returns (bool) {
    return sspRegistry.isRegistered(key);
  }

  // FIELDS

  SSPRegistry public sspRegistry;
}
