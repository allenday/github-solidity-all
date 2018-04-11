pragma solidity ^0.4.13;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/Liquet.sol";

contract TestLiquet {

  function testInitialBalanceUsingDeployedContract() {
    Liquet liquet = Liquet(DeployedAddresses.Liquet());

    uint expected = liquet.totalSupply();

    Assert.equal(liquet.balanceOf(msg.sender), expected, "Owner should have 10,000,000 Liquets initially");
  }

  function testDecimalsUsingDeployedContract() {
    Liquet liquet = Liquet(DeployedAddresses.Liquet());

    Assert.equal(liquet.decimals(), 18, "The decimals should be 18");
  }
}
