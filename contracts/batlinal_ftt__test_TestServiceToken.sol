pragma solidity ^0.4.4;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/ServiceToken.sol";

contract TestServiceToken {
  /*address public beneficiary = 0xC52edCdea8d5458C7F3FC3e16D7CC454b6893508;

  function testUnexpiredBalance() {
    ServiceToken st = ServiceToken(DeployedAddresses.ServiceToken());

    uint unExpiredEpoch = 1507455300;
    st.setEpochNow(unExpiredEpoch);
    Assert.equal(st.epochNow(), unExpiredEpoch, "Time now should be 1507455300");

    uint totalSupply = 240;
    Assert.equal(st.balanceOf(beneficiary), totalSupply, "Beneficiary should have 240 ServiceTokens initially");
  }

  function testExpiredBalance() {
    ServiceToken st = ServiceToken(DeployedAddresses.ServiceToken());

    uint expiredEpoch = 1538991300;
    st.setEpochNow(expiredEpoch);
    Assert.equal(st.epochNow(), expiredEpoch, "Time now should be 1538991300");

    uint totalSupply = 0;
    Assert.equal(st.balanceOf(beneficiary), totalSupply, "Beneficiary should have 0 ServiceTokens initially");
  }*/
}
