pragma solidity ^0.4.11;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/Exchange.sol";
import "../contracts/FIXED.sol";

contract TestExchange {
  function testDepositUsingDeployedContract() {
    Exchange exchange = Exchange(DeployedAddresses.Exchange());
    FIXED fixed = FIXED(DeployedAddresses.FIXED());

    exchange.deposit(fixed, 50000);

    uint expected = 50000;
    Assert.equal(fixed.getBalance(exchange), expected, "Exchange should have 50000 after deposit");
  }
}
