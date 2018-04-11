pragma solidity ^0.4.16;

import "wafr/Test.sol";
import "utils/MembershipRegistry.sol";
import "utils/IProxy.sol";


contract FakeMembershipRegistry is MembershipRegistry {
  function FakeMembershipRegistry(address _owner) {
    proxy = IProxy(_owner);
  }
}

contract MembershipRegistryTest is Test {
  FakeMembershipRegistry reg;

  function setup() {
    reg = new FakeMembershipRegistry(address(this));
  }

  function test_0_ensureRegistryFunctions() {
    reg.addMember(msg.sender);
    assertEq(reg.isMember(msg.sender), true);
    reg.removeMember(msg.sender);
    assertEq(reg.isMember(msg.sender), false);
  }
}
