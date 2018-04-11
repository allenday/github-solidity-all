pragma solidity ^0.4.13;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/FiatBase.sol";
import "../contracts/OpenBids.sol";
import "../contracts/time/DebugClock.sol";

contract TestOpenBids {
  // Truffle will send the TestContract one Ether after deploying the contract.
  uint public initialBalance = 90 ether;

  FiatBase fiatcoin;
  OpenBids ob;
  DebugClock clock;

  function testOne() {
    Assert.equal(this.balance, 90 ether, "should have ether");
    fiatcoin = new FiatBase();
    clock = new DebugClock(now);
    uint time_now = clock.get_time();
    ob = new OpenBids(
      fiatcoin,
      1 hours,
      this,
      clock,
      10,
      10 ether);
    fiatcoin.mint(this, 1000 ether);
    Assert.equal(fiatcoin.balanceOf(this), 1000 ether, "this has fiatcoins");
    Assert.equal(fiatcoin.transfer(ob, 1000 ether), true, "transfer fiatcoins to OpenBids contract");
    Assert.equal(fiatcoin.balanceOf(ob), 1000 ether, "ob has fiatcoins");
    Assert.equal(ob.getBidsLength(), 0, "bids len 0");
    ob.bid.value(2000 finney)(5 ether);
    ob.bid.value(200 finney)(5 ether);
    clock.set_time(time_now + 2 hours);
    ob.auctionEnd();
    Assert.equal(ob.finalRate(), 25000 finney, "final rate is correct");
    Assert.equal(ob.balance, 2200 finney, "bid has money");
    uint allowanceFiat;
    uint allowanceEth;
    (allowanceFiat, allowanceEth) = ob.biddersAllowances(this);
    Assert.equal(allowanceFiat, 10 ether, "bids has the right fiat allowances");
    Assert.equal(allowanceEth, 1800 finney, "bids has the right ether allowances");
  }
}