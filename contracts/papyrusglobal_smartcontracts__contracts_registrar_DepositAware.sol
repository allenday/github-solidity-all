pragma solidity ^0.4.18;

import "../common/WithToken.sol";
import "../registry/DepositRegistry.sol";


contract DepositAware is WithToken {

  // INTERNAL FUNCTIONS
  
  function returnDeposit(address depositAccount, DepositRegistry depositRegistry) internal {
    if (depositRegistry.isRegistered(depositAccount)) {
      uint256 amount = depositRegistry.getDeposit(depositAccount);
      address depositOwner = depositRegistry.getDepositOwner(depositAccount);
      if (amount > 0) {
        token.transfer(depositOwner, amount);
        depositRegistry.unregister(depositAccount);
      }
    }
  }
}
