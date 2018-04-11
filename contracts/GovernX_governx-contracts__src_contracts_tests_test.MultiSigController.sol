pragma solidity ^0.4.16;

import "wafr/Test.sol";

import "MultiSigController.sol";
import "utils/Proxy.sol";
import "utils/HelperMethods.sol";

contract TestEndpoint {
  uint256 public val;

  function set() public {
    val = 4500;
  }
}

contract SigUser {
  MultiSigController wallet;

  function SigUser(address _wallet) {
    wallet = MultiSigController(_wallet);
  }

  function newProposal(string meta, bytes data) public returns (uint256) {
    return wallet.newProposal(meta, data);
  }

  function vote(uint256 _proposalID, uint256 _position, uint256 _weight) public {
    wallet.vote(_proposalID, _position, _weight);
  }

  function execute(uint256 _proposalID) public {
    wallet.execute(_proposalID);
  }

  function addMember(address _member) public {
    wallet.addMember(_member);
  }

  function removeMember(address _member) public {
    wallet.removeMember(_member);
  }

  function _addMember(address _member) public {
    wallet.addMember(_member);
  }

  function _removeMember(address _member) public {
    wallet.removeMember(_member);
  }
}

contract MultiSigControllerTest is Test {
  MultiSigController controller;
  Proxy proxy;
  TestEndpoint endpoint;
  bytes emptyBytes;
  address[] members;
  SigUser user;

  function setup() {
    members.push(address(this));
    uint256 required = 1;

    proxy = new Proxy();
    endpoint = new TestEndpoint();
    controller = new MultiSigController(address(proxy), members, required);
    user = new SigUser(controller);
  }

  function test_0_testBasicTxProposal() {
    assertEq(0, controller.newProposal("", emptyBytes));
    assertEq(controller.hasVoted(0, address(this)), false);
    assertEq(controller.latestMomentOf(0, address(this)), 0);
    controller.vote(0, 1, 1); // FIX THIS!!!
  }

  function test_1_restrictDoubleVote_shouldThrow() {
    controller.vote(0, 1, 1);
  }

  function test_2_accessRestriction_newProposal_shouldThrow() {
    user.newProposal("", emptyBytes);
  }

  function test_3_accessRestriction_vote_shouldThrow() {
    user.vote(0, 1, 1);
  }

  function test_4_accessRestriction_execute_shouldThrow() {
    user.execute(0);
  }

  function test_5_accessRestriction_addMember_shouldThrow() {
    user.addMember(address(user));
  }

  function test_6_accessRestriction_removeMember_shouldThrow() {
    user.removeMember(address(user));
  }

  function test_7_accessRestriction_UnderscoreRemoveMember_shouldThrow() {
    user._removeMember(address(user));
  }

  function test_8_accessRestriction_UnderscoreAddMember_shouldThrow() {
    user._addMember(address(user));
  }
}
