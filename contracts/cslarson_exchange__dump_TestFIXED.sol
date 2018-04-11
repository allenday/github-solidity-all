pragma solidity ^0.4.11;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/FIXED.sol";

contract TestFIXED {
  function testInitialBalanceUsingDeployedContract() {
    FIXED fixed = FIXED(DeployedAddresses.FIXED());

    uint expected = 1000000;

    Assert.equal(fixed.getBalance(tx.origin), expected, "Owner should have 1000000 FIXED initially");
  }
}
