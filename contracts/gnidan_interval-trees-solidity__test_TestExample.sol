pragma solidity ^0.4.15;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";

import "../contracts/Example.sol";

contract TestExample {
  Example trees;

  function beforeAll() {
    trees = Example(DeployedAddresses.Example());
  }

  function test0_adding() {
    uint TREE_ID = 0x8800;
    bytes32 DATA = 0x417412;

    uint begin;
    uint end;
    bytes32 data;

    trees.addInterval(TREE_ID, 3, 7, DATA);

    Assert.equal(trees.numIntervals(TREE_ID), 1, "Tree should have 1 interval");

    Assert.equal(trees.intervalsAt(TREE_ID, 4), 1, "Tree should return interval at point");
    (begin, end, data) = trees.intervalAt(TREE_ID, 4, 0);

    Assert.equal(begin, 3, "Begin should match");
    Assert.equal(end, 7, "End should match");
    Assert.equal(data, DATA, "Data should match");
  }
}
