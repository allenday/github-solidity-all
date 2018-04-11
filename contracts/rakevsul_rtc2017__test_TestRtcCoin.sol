pragma solidity ^0.4.2;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/RtcCoin.sol";

contract TestRtcCoin {

  function testInitialBalanceUsingDeployedContract() {
    RtcCoin rtccoin = RtcCoin(DeployedAddresses.RtcCoin());

    uint expected = 10000;

    Assert.equal(rtccoin.balances(tx.origin), expected, "Owner should have 10000 MetaCoin initially");
  }
}
