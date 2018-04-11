pragma solidity ^0.4.16;

import "wafr/Test.sol";

import "OpenController.sol";
import "utils/Proxy.sol";
import "utils/HelperMethods.sol";

contract TestEndpoint {
  uint256 public val;

  function set() public {
    val = 4500;
  }
}

contract OpenControllerTest is Test {
  OpenController controller;
  Proxy proxy;
  TestEndpoint endpoint;
  bytes emptyBytes;

  function setup() {
    proxy = new Proxy();
    endpoint = new TestEndpoint();
    controller = new OpenController(address(proxy));
  }

  function test_0_testBasicTxExecution() {
    // bytes memory data = HelperMethods.proposalData("set()", address(endpoint), 0, emptyBytes);
    // log_uint(22, data);
    // controller.newProposal("", data);
    // controller.execute(0);
  }
}
