pragma solidity ^0.4.13;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/LibSort.sol";

contract TestLibSort {
  LibSort sort;

  function testInitialA() {
    sort = new LibSort();
    Assert.equal(sort.length(), 0, "should be sorted");
    sort.push(0, 10);
    sort.push(1, 5);
    sort.sort(false);
    Assert.equal(sort.length(), 2, "should be sorted");
    uint index;
    uint value;
    (index, value) = sort.get(0);
    Assert.equal(index, 1, "should be sorted");
    Assert.equal(value, 5, "should be sorted");
    (index, value) = sort.get(1);
    Assert.equal(index, 0, "should be sorted");
    Assert.equal(value, 10, "should be sorted");
  }
}