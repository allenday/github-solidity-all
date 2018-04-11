pragma solidity ^0.4.8;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/RVRCoin.sol";

contract TestRVRCoin {

  address testAccount = 0xd05d276b7ce7c0cd1b3fb74d83705e2d3b46c62d;

  function testConstructorUsingDeployedContract() {
    RVRCoin rvrcoin = RVRCoin(DeployedAddresses.RVRCoin());
    uint expected = 100;

    Assert.equal(rvrcoin.getBalance(tx.origin), expected, "Owner should have 100 coins initially");
  }

  function testConstructorUsingNewContract() {
    RVRCoin rvrcoin = new RVRCoin();
    uint expected = 100;

    Assert.equal(rvrcoin.getBalance(tx.origin), expected, "Owner should have 100 coins initially");
  }

  function testDefaultWallet() {
    RVRCoin rvrcoin = RVRCoin(DeployedAddresses.RVRCoin());
    /*RVRCoin rvrcoin = new RVRCoin({gas: 3000000});*/
    uint expected = 50;
    rvrcoin.defaultWallet(testAccount);
    Assert.equal(rvrcoin.getBalance(testAccount), expected, "testAccount should have 50 coins");
  }

  function testDeductCoin() {
    RVRCoin rvrcoin = RVRCoin(DeployedAddresses.RVRCoin());
    /*RVRCoin rvrcoin = new RVRCoin({gas: 3000000});*/
    uint expected = 30;
    rvrcoin.defaultWallet(testAccount);
    rvrcoin.deductCoin(testAccount, 20);
    Assert.equal(rvrcoin.getBalance(testAccount), expected, "testAccount should have 30 coins");
  }

}
