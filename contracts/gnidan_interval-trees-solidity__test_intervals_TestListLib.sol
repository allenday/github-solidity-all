pragma solidity ^0.4.15;

import "truffle/Assert.sol";

import "../../contracts/intervals/ListLib.sol";

contract TestListLib {
  // TODO avoid redefinition here
  uint constant SEARCH_DONE = 0x00;
  uint constant SEARCH_EARLIER = 0x01;
  uint constant SEARCH_LATER = 0x10;

  using ListLib for ListLib.List;

  ListLib.List intervals;

  function test0_create() {
    intervals = ListLib.createNew();
    Assert.equal(intervals.length, 0, "Initial list should be empty");
  }

  function test1_addingFirst() {
    intervals.add(3, 7, 1);

    Assert.equal(intervals.length, 1, "Added intervals should be counted");
    Assert.equal(intervals.center, 5, "Center should update on first add");
  }

  function test2_addingSecond() {
    var oldCenter = intervals.center;
    var oldLowest = intervals.lowestBegin;
    var oldHighest = intervals.highestEnd;

    intervals.add(1, 6, 2);

    Assert.equal(intervals.length, 2, "Added intervals should be counted");
    Assert.equal(intervals.center, oldCenter, "List center should not change");
    Assert.notEqual(intervals.lowestBegin, oldLowest, "Lowest beginning interval should update");
    Assert.equal(intervals.highestEnd, oldHighest, "Highest ending interval should not update");
  }

  function test3_searchNext() {
    /*
     *   0   1   2   3   4   5   6   7   8   9
     *                     center
     *               *-------|-------o
     *       *---------------|---o
     *
     *    search hint behavior:
     *
     *                       *
     *                done with search
     *
     *   <:::::::::::::::::::o
     *       search earlier
     *                       o:::::::::::::::>
     *                          search later
     *
     *   0   1   2   3   4   5   6   7   8   9
     */

    uint[] memory matchingIDs;
    uint8 searchNext;

    /*
     * case: search done
     */
    (matchingIDs, searchNext) = intervals.matching(5);
    Assert.equal(uint(searchNext), SEARCH_DONE, "Searching overlaps at center finishes search");

    /*
     * case: search earlier
     */
    (matchingIDs, searchNext) = intervals.matching(4);
    assert(matchingIDs.length > 0);  // interval containing point exists
    Assert.equal(uint(searchNext), SEARCH_EARLIER, "less than center w/ matches yields SEARCH_EARLIER");

    (matchingIDs, searchNext) = intervals.matching(0);
    assert(matchingIDs.length == 0);  // no interval containing point
    Assert.equal(uint(searchNext), SEARCH_EARLIER, "less than center w/o matches yields SEARCH_EARLIER");

    /*
     * case: search later
     */
    (matchingIDs, searchNext) = intervals.matching(6);
    assert(matchingIDs.length > 0);  // interval containing point exists
    Assert.equal(uint(searchNext), SEARCH_LATER, "greater than center w/ matches yields SEARCH_LATER");

    (matchingIDs, searchNext) = intervals.matching(7);
    assert(matchingIDs.length == 0);  // no interval containing point
    Assert.equal(uint(searchNext), SEARCH_LATER, "greater than center w/o matches yields SEARCH_LATER");

  }
}
