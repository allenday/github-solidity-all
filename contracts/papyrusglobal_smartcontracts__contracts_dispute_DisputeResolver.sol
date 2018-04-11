pragma solidity ^0.4.18;

import "../common/WithToken.sol";
import "../registry/ArbiterRegistry.sol";
import "../registry/DisputeRegistry.sol";


contract DisputeResolver is WithToken {

  // PUBLIC FUNCTIONS

  function startDispute(address subject) public {
    Dispute dispute = new Dispute(token, msg.sender, subject);
    Arbiter[] memory arbiters = new Arbiter[](NUMBER_OF_ARBITERS_FOR_DISPUTE);
    for (uint256 i = 0; i < NUMBER_OF_ARBITERS_FOR_DISPUTE; i++) {
      arbiters[i] = arbiterRegistry.getRandomArbiter();
      // TODO check for duplicates
    }
    dispute.addArbiters(arbiters);
  }

  // FIELDS

  DisputeRegistry internal disputeRegistry;
  ArbiterRegistry internal arbiterRegistry;

  uint8 private constant NUMBER_OF_ARBITERS_FOR_DISPUTE = 5;
}
