pragma solidity ^0.4.15;

import "truffle/Assert.sol";

import "../../contracts/intervals/TreeLib.sol";

contract TestTreeLib {
  using TreeLib for TreeLib.Tree;

  TreeLib.Tree tree;

  function test0_firstInterval() {
    tree.addInterval(1, 9, 0x1);  // center will be 5
    Assert.equal(tree.numIntervals, 1, "There should be 1 interval");

    Assert.equal(tree.search(5).length, 1, "Point search should find 1 interval");
    Assert.equal(tree.search(0).length, 0, "Strictly below interval should find 0 intervals");
    Assert.equal(tree.search(9).length, 0, "Upper boundary exact match should find 0 intervals");
  }

  function test1_overlappingIntervalSameNode() {
    tree.addInterval(4, 7, 0x2);
    Assert.equal(tree.numIntervals, 2, "There should be 2 intervals");

    Assert.equal(tree.search(5).length, 2, "Common point should have both intervals");
    Assert.equal(tree.search(3).length, 1, "Non-overlapped point should only have first interval");
    Assert.equal(tree.search(7).length, 1, "Upper-bound on only 1 should find 1 match");
  }

  function test2_verlappingIntervalNewNode() {
    tree.addInterval(3, 4, 0x3);
    Assert.equal(tree.numIntervals, 3, "There should be 3 intervals");

    Assert.equal(tree.search(5).length, 2, "Point not in new should find only 2 prior");
    Assert.equal(tree.search(3).length, 2, "Common point should find 2 intervals");
    Assert.equal(tree.search(4).length, 2, "Upper-bound on only 2 should find 1 match");
  }

  function test3_search() {
    uint[] memory results;
    uint intervalID;
    uint begin;
    uint end;
    bytes32 data;

    results = tree.search(1);
    Assert.equal(results.length, 1, "There should only be 1 search result");

    intervalID = results[0];
    (begin, end, data) = tree.getInterval(intervalID);

    Assert.equal(begin, 1, "Returned interval should begin at 1");
    Assert.equal(end, 9, "Returned interval should end at 9");
    Assert.equal(data, 0x1, "Returned interval should have matching data");
  }

  function test4_searchSameNode() {
    uint[] memory results;
    uint intervalID;
    uint begin;
    uint end;
    bytes32 data;
    uint i;

    results = tree.search(4);
    Assert.equal(results.length, 2, "There should be two results");

    for (i = 0; i < results.length; i++) {
      intervalID = results[i];

      (begin, end, data) = tree.getInterval(intervalID);

      if ( !(begin == 1 && end == 9 && data == 0x1) ) {
        Assert.equal(begin, 4, "The other result should be (4,7,0x2)");
        Assert.equal(end, 7, "The other result should be (4,7,0x2)");
        Assert.equal(data, 0x2, "The other result should be (4,7,0x2)");
      }
    }
  }

  function test5_searchAcrossNodes() {
    uint[] memory results;
    uint intervalID;
    uint begin;
    uint end;
    bytes32 data;
    uint i;

    results = tree.search(3);
    Assert.equal(results.length, 2, "There should be two results");

    for (i = 0; i < results.length; i++) {
      intervalID = results[i];

      (begin, end, data) = tree.getInterval(intervalID);

      if ( !(begin == 1 && end == 9 && data == 0x1) ) {
        Assert.equal(begin, 3, "The other result should be (3,4,0x2)");
        Assert.equal(end, 4, "The other result should be (3,4,0x2)");
        Assert.equal(data, 0x3, "The other result should be (3,4,0x2)");
      }
    }
  }
}
