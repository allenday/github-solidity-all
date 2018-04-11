pragma solidity ^0.4.15;

import "./intervals/TreeLib.sol";

contract Example {
  // maps sha3(msg.sender, id) to interval tree
  mapping (bytes32 => TreeLib.Tree) trees;

  using TreeLib for TreeLib.Tree;

  function ExampleIntervalTree() {
  }

  function addInterval(uint treeID, uint begin, uint end, bytes32 data) {
    var tree = trees[getHash(msg.sender, treeID)];

    tree.addInterval(begin, end, data);
  }

  function numIntervals(uint treeID) constant returns (uint) {
    var tree = trees[getHash(msg.sender, treeID)];

    return tree.numIntervals;
  }

  function intervalsAt(uint treeID, uint point)
    constant
    returns (uint)
  {
    var tree = trees[getHash(msg.sender, treeID)];

    return tree.search(point).length;
  }

  function intervalAt(uint treeID, uint point, uint offset)
    constant
    returns (uint begin, uint end, bytes32 data)
  {
    var tree = trees[getHash(msg.sender, treeID)];

    var results = tree.search(point);
    require(offset < results.length);

    return tree.getInterval(results[offset]);
  }

  function getHash(address owner, uint treeID)
    constant
    internal
    returns (bytes32)
  {
    return sha3(owner, treeID);
  }
}
