pragma solidity ^0.4.2;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/TrustToken.sol";

contract TestTrusttoken {
  // Test the intial token supply
  function testInitialTokenBalance() public {
    TrustToken token = TrustToken(DeployedAddresses.TrustToken());
    uint expected = 1000000;
    Assert.equal(token.balanceOf(tx.origin), expected, "Owner should have 1 000 000 TrustToken initially");
  }

  // Test the token transfer
  function testTransferToken() public { 
    TrustToken token = new TrustToken();
    address account_one = 0x1234567890123456789012345678901234567890;
    Assert.equal(token.transfer(account_one, 100), false, "It should not be possible to transfer token to non-registered account");
  }
}
