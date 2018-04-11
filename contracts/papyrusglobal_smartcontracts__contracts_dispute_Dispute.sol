pragma solidity ^0.4.18;

import "../common/SafeOwnable.sol";
import "../common/ERC20.sol";
import "./Arbiter.sol";


contract Dispute is SafeOwnable {

  // STRUCTURES

  struct Voter {
    Arbiter arbiter;
    bool isVoted;
    bool vote;
    bool exists;
  }

  // PUBLIC FUNCTIONS

  function Dispute(ERC20 papyrusToken, address creatorAddress, address subjectAddress) public {
    token = papyrusToken;
    creator = creatorAddress;
    subject = subjectAddress;
  }

  function addArbiters(Arbiter[] arbiters) public onlyOwner {
    for (uint256 i = 0; i < arbiters.length; i++) {
      Arbiter arbiter = arbiters[i];
      address arbiterAddress = arbiter.arbiterAddress();
      if (voters[arbiterAddress].exists) {
        voters[arbiterAddress].arbiter = arbiter;
        voters[arbiterAddress].isVoted = false;
        voters[arbiterAddress].exists = true;
        voterList.push(voters[arbiterAddress]);
      } else {
        revert();
      }
    }
  }

  function vote(bool _vote) public onlyArbiter {
    if (!solved && !voters[msg.sender].isVoted) {
      voters[msg.sender].vote = _vote;
      voters[msg.sender].isVoted = true;
      votedCount++;
      if (_vote) {
        forCount++;
      } else {
        againstCount++;
      }
      checkSolved();
    } else {
      revert();
    }
  }

  function isSolved() public view returns (bool) {
    return solved;
  }

  // PRIVATE FUNCTIONS

  function checkSolved() private {
    if (forCount > voterList.length / 2) {
      decision = true;
      solve();
    } else if (againstCount > voterList.length / 2) {
      decision = false;
      solve();
    }
  }

  function solve() private {
    solved = true;
    //TODO: Money + Karma thing
  }

  // MODIFIERS

  modifier onlyArbiter() {
    require(voters[msg.sender].exists);
    _;
  }

  // FIELDS

  ERC20 token;
  address private creator;
  address private subject;

  mapping(address => Voter) voters;
  Voter[] voterList;

  uint64 votedCount;
  uint64 forCount;
  uint64 againstCount;
  bool solved;
  bool decision;
}
