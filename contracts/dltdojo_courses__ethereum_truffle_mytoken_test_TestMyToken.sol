pragma solidity ^0.4.12;
// http://truffleframework.com/docs/getting_started/solidity-tests

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/MyToken.sol";

contract TestMyToken {

  function testInitialBalanceUsingDeployedContract() {
    MyToken mtoken = MyToken(DeployedAddresses.MyToken());

    uint expected = 12000;

    Assert.equal(mtoken.balanceOf(tx.origin), expected, "Owner should have 12000 MyToken initially");
  }
  
  function testInitialBalanceWithNew() {

    MyToken mtoken = new MyToken();

    // The global variable "this" is the contract address.
    Assert.equal(mtoken.balanceOf(this), 12000, "Owner should have 12000 MyToken initially");

    // https://ethereum.stackexchange.com/questions/1891/whats-the-difference-between-msg-sender-and-tx-origin
    Assert.equal(mtoken.balanceOf(tx.origin), 0, "tx.origin address should have 0 MyToken initially");
  }

}
