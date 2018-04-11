pragma solidity ^0.4.18;

import "../common/SafeOwnable.sol";
import "../common/ERC20.sol";
import "./Dispute.sol";


contract Arbiter is SafeOwnable {

  // STRUCTURES

  struct DisputeBean {
    Dispute dispute;
    uint256 index;
    bool exists;
  }

  // PUBLIC FUNCTIONS

  function Arbiter(address _arbiterAddress) public {
    arbiterAddress = _arbiterAddress;
  }

  function assignDispute(Dispute dispute) public onlyOwner {
    if (!toSolveMapping[dispute].exists) {
      disputesToSolve.push(dispute);
      DisputeBean memory bean = DisputeBean(dispute, disputesToSolve.length - 1, true);
      toSolveMapping[address(dispute)] = bean;
    }
  }

  function solve(Dispute dispute, bool vote) public onlyArbiter {
    if (toSolveMapping[dispute].exists) {
      if (!dispute.isSolved()) {
        dispute.vote(vote);
      }
      moveToSolved(dispute);
    }
  }

  function skip(Dispute dispute) public onlyArbiter {
    moveToSolved(dispute);
  }

  function gainKarma(int256 gained) public onlyOwner returns (int256) {
    karma = karma + gained;
    return karma;
  }

  function getKarma() public view returns (int256) {
    return karma;
  }

  function getDisputesToSolve() public view returns (address[] disputeAddresses) {
    disputeAddresses = new address[](disputesToSolve.length);
    for (uint256 i = 0; i < disputesToSolve.length; i++) {
      disputeAddresses[i] = address(disputesToSolve[i]);
    }
  }

  // PRIVATE FUNCTIONS

  function moveToSolved(Dispute dispute) private {
    DisputeBean storage bean = toSolveMapping[dispute];
    disputesToSolve[bean.index] = disputesToSolve[disputesToSolve.length - 1];
    disputesToSolve.length--;
    solvedDisputes.push(dispute);
  }

  // MODIFIERS

  modifier onlyArbiter() {
    require(msg.sender == arbiterAddress);
    _;
  }

  // FIELDS
  
  address public arbiterAddress;
  
  int256 public karma;

  mapping(address => DisputeBean) toSolveMapping;

  Dispute[] disputesToSolve;
  Dispute[] solvedDisputes;
}
