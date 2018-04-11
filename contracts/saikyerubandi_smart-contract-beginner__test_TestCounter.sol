pragma solidity ^0.4.2;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/Counter.sol";

contract TestCounter {

  function testNewCounterValueIszero() {
    Counter counter = Counter(DeployedAddresses.Counter());

    uint expected = 0;

    Assert.equal(counter.value(), expected, "New Counter should start with zero");
  }

  function testNewCounterValueAfterAIncrease() {
    Counter counter = new Counter();

    counter.increase();
    uint expected = 1;

    Assert.equal(counter.value(), expected, "Counter value should be 1");
  }

  function testNewCounterValueAfterADecrease() {
    Counter counter = new Counter();

    counter.decrease();
    uint expected = 0;

    Assert.equal(counter.value(), expected, "Counter value should be 0");
  }

  function testNewCounterValueAfterAIncreaseAndADecrease() {
    Counter counter = new Counter();

    counter.increase();
    counter.decrease();
    uint expected = 0;

    Assert.equal(counter.value(), expected, "Counter value should be 0");
  }


}
