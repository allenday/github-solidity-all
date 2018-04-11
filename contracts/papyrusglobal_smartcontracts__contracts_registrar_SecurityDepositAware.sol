pragma solidity ^0.4.18;

import "../registry/DepositRegistry.sol";
import "./DepositAware.sol";


contract SecurityDepositAware is DepositAware {

  // INTERNAL FUNCTIONS

  function receiveSecurityDeposit(address depositAccount) internal {
    token.transferFrom(msg.sender, this, SECURITY_DEPOSIT_SIZE);
    securityDepositRegistry.register(depositAccount, SECURITY_DEPOSIT_SIZE, msg.sender);
  }

  function transferSecurityDeposit(address depositAccount, address newOwner) internal {
    securityDepositRegistry.transfer(depositAccount, newOwner, msg.sender);
  }

  // FIELDS

  DepositRegistry public securityDepositRegistry;

  uint256 private constant SECURITY_DEPOSIT_SIZE = 10;
}
