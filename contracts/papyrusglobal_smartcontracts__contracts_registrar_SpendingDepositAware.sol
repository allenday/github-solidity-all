pragma solidity ^0.4.18;

import "../registry/DepositRegistry.sol";
import "./DepositAware.sol";


contract SpendingDepositAware is DepositAware {

  // INTERNAL FUNCTIONS

  function receiveSpendingDeposit(address depositSender, uint256 amount) internal {
    token.transferFrom(depositSender, this, amount);
    // TODO: What if transfer is failed?
    if (spendingDepositRegistry.isRegistered(depositSender)) {
      spendingDepositRegistry.refill(depositSender, amount);
    } else {
      spendingDepositRegistry.register(depositSender, amount, msg.sender);
    }
  }

  function spendDeposit(address spender, address receiver, uint256 amount) internal returns (bool) {
    spendingDepositRegistry.spend(spender, amount);
    token.transfer(receiver, amount);
    // TODO: What if transfer is failed?
  }

  // FIELDS
  
  DepositRegistry public spendingDepositRegistry;
}
