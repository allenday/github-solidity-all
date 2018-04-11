pragma solidity ^0.4.16;

import "wafr/Test.sol";
import "OpenController.sol";


contract ControllerTest is Test {
  OpenController controller;
  bytes propData = "";
  bytes32[] vote;

  function setup() {
    controller = new OpenController(address(this));
  }

  function test_0_ensureControllerWorks() {
    assertEq(controller.newProposal("Something", propData), uint256(0));

    assertEq(controller.numProposals(), uint256(1));
    assertEq(controller.numMomentsOf(0), uint256(1));
    assertEq(controller.momentSenderOf(0, 0), address(this));
    assertEq(controller.momentBlockOf(0, 0), block.number);
    assertEq(controller.momentTimeOf(0, 0), block.timestamp);
    assertEq(controller.momentNonceOf(0, 0), uint256(0));
    assertEq(controller.momentValueOf(0, 0), uint256(0));
    assertEq(controller.hasExecuted(0), false);
  }

  function test_1_ensureVoteWorks_increaseBlocksBy100() {
    vote.push(1);
    controller.vote(0, 1, 1);

    assertEq(controller.numProposals(), uint256(1));
    assertEq(controller.numMomentsOf(0), uint256(2));
    assertEq(controller.momentSenderOf(0, 1), address(this));
    assertEq(controller.momentBlockOf(0, 1), block.number);
    assertEq(controller.momentTimeOf(0, 1), block.timestamp);
    assertEq(controller.momentNonceOf(0, 1), uint256(1));
    assertEq(controller.momentValueOf(0, 1), uint256(0));
    assertEq(controller.hasExecuted(0), false);
  }

  function test_2_ensureProposalExecution_increaseBlocksBy100() {

  }
}
