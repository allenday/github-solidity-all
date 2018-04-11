pragma solidity ^0.4.18;

import "../registry/AuditorRegistry.sol";
import "./SecurityDepositAware.sol";


contract AuditorRegistrar is SecurityDepositAware {

  // EVENTS

  event AuditorRegistered(address indexed auditorAddress);
  event AuditorUnregistered(address indexed auditorAddress);

  // PUBLIC FUNCTIONS

  /// @dev Register organisation as Auditor
  function registerAuditor(address auditorAddress) public {
    receiveSecurityDeposit(auditorAddress);
    auditorRegistry.register(auditorAddress, msg.sender);
    AuditorRegistered(auditorAddress);
  }

  /// @dev Unregister Auditor and return unused deposit
  function unregisterAuditor(address auditorAddress) public {
    returnDeposit(auditorAddress, securityDepositRegistry);
    auditorRegistry.unregister(auditorAddress, msg.sender);
    AuditorUnregistered(auditorAddress);
  }

  /// @dev Transfer ownership of this Auditor record
  function transferAuditorRecord(address key, address newOwner) public {
    auditorRegistry.transfer(key, newOwner, msg.sender);
  }

  /// @dev Retrieve information about registered Auditor
  function findAuditor(address auditor)
    public
    view
    returns (address auditorAddress, uint256[2] karma, address recordOwner)
  {
    return auditorRegistry.getAuditor(auditor);
  }

  /// @dev Ccheck if Auditor registered
  function isAuditorRegistered(address key) public view returns (bool) {
    return auditorRegistry.isRegistered(key);
  }

  // FIELDS
  
  AuditorRegistry public auditorRegistry;
}
