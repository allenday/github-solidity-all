pragma solidity ^0.4.2;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/DTransport.sol";

contract TestDTransport {

  function testWIP() {
    DTransport dt = DTransport(DeployedAddresses.DTransport());

    uint expected = 1;

    Assert.equal(expected, expected, "This test should pass WIP");
  }
}
