pragma solidity ^0.4.16;

import "wafr/Test.sol";

import "OpenControllerFactory.sol";
import "utils/Proxy.sol";


contract OpenControllerFactoryTest is Test {
  OpenControllerFactory factory;

  function setup() {
    factory = new OpenControllerFactory();
  }

  function test_0_createOpenController_test_methods() {
    Proxy proxy = Proxy(factory.createProxy());
    OpenController controller = OpenController(proxy.owner());

    assertEq(controller.numProposals(), uint256(0));
  }
}
