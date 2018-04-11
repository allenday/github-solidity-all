pragma solidity ^0.4.18;

import "../dao/DaoOwnable.sol";
import "../dispute/Dispute.sol";


contract DisputeRegistry is DaoOwnable {

  // PUBLIC FUNCTIONS

  function registerDispute(Dispute dispute) public onlyDaoOrOwner {
    disputes[address(dispute)] = dispute;
  }

  function findDispute(address disputeAddress) public view returns (address) {
    return address(disputes[disputeAddress]);
  }

  // FIELDS

  mapping(address => Dispute) disputes;
}
