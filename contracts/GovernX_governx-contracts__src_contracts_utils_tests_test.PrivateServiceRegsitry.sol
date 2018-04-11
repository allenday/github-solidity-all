pragma solidity ^0.4.16;

import "wafr/Test.sol";
import "utils/PrivateServiceRegistry.sol";

contract FakePrivateServiceRegistry is PrivateServiceRegistry {
  function newService() public returns (address service) {
    service = address(new PrivateServiceRegistry());
    register(service);
  }
}

contract PrivateServiceRegistryTest is Test {
  FakePrivateServiceRegistry reg;

  function setup() {
    reg = new FakePrivateServiceRegistry();
  }

  function test_0_ensureServiceRegistryFunctions() {
    address someService = reg.newService();
    assertEq(reg.isService(someService), true);
    address someService2 = reg.newService();
    assertEq(reg.isService(someService2), true);
  }
}
