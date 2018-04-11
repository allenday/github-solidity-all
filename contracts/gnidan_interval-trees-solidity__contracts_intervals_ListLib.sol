pragma solidity ^0.4.15;

import "../vendor/grove/GroveLib.sol";

import "./IntervalLib.sol";

library ListLib {
  uint8 constant SEARCH_DONE = 0x00;
  uint8 constant SEARCH_EARLIER = 0x01;
  uint8 constant SEARCH_LATER = 0x10;

  using GroveLib for GroveLib.Index;
  using IntervalLib for IntervalLib.Interval;

  struct List {
    uint length;
    uint center;

    // maps item ID to items
    mapping (uint => IntervalLib.Interval) items;

    GroveLib.Index beginIndex;
    GroveLib.Index endIndex;
    bytes32 lowestBegin;
    bytes32 highestEnd;
  }

  function createNew()
    internal
    returns (List)
  {
    return createNew(block.number);
  }

  function createNew(uint id)
    internal
    returns (List)
  {
    return List({
      length: 0,
      center: 0xDEADBEEF,
      lowestBegin: 0x0,
      highestEnd: 0x0,
      beginIndex: GroveLib.Index(sha3(this, bytes32(id * 2))),
      endIndex: GroveLib.Index(sha3(this, bytes32(id * 2 + 1)))
    });
  }

  function add(List storage list, uint begin, uint end, uint intervalID) internal {
    var _intervalID = bytes32(intervalID);
    var _begin = _getBeginIndexKey(begin);
    var _end = _getEndIndexKey(end);

    list.beginIndex.insert(_intervalID, _begin);
    list.endIndex.insert(_intervalID, _end);
    list.length++;

    if (list.length == 1) {
      list.lowestBegin = list.beginIndex.root;
      list.highestEnd = list.endIndex.root;
      list.center = begin + (end - begin) / 2;

      return;
    }

    var newLowest = list.beginIndex.getPreviousNode(list.lowestBegin);
    if (newLowest != 0x0) {
      list.lowestBegin = newLowest;
    }

    var newHighest = list.endIndex.getNextNode(list.highestEnd);
    if (newHighest != 0x0) {
      list.highestEnd = newHighest;
    }
  }

  /*
   * @dev Searches interval list for:
   *   - matching intervals
   *   - information on how search should proceed
   * @param node The node to search
   * @param point The point to search for
   */
  function matching(List storage list, uint point)
    constant
    internal
    returns (uint[] memory intervalIDs, uint8 searchNext)
  {
    uint[] memory _intervalIDs = new uint[](list.length);
    uint num = 0;

    bytes32 cur;

    if (point == list.center) {
      /*
       * case: point exactly matches the list's center
       *
       * collect (all) matching intervals (every interval in list, by def)
       */
      cur = list.lowestBegin;
      while (cur != 0x0) {
	_intervalIDs[num] = uint(list.beginIndex.getNodeId(cur));
	num++;
	cur = _next(list, cur);
      }

      /*
       * search is done:
       * no other nodes in tree have intervals containing point
       */
      searchNext = SEARCH_DONE;
    } else if (point < list.center) {
      /*
       * case: point is earlier than center.
       *
       *
       * collect matching intervals.
       *
       * shortcut:
       *
       *   starting with lowest beginning interval, search sorted begin list
       *   until begin is later than point
       *
       *	       point
       *                 :
       *                 :   center
       *                 :     |
       *        (0) *----:-----|----------o
       *        (1)    *-:-----|---o
       *        (-)      x *---|------o
       *        (-)         *--|--o
       *        (-)          *-|----o
       *
       *
       *    this works because intervals contained in an interval list are
       *    guaranteed tocontain `center`
       */
      cur = list.lowestBegin;
      while (cur != 0x0) {
	uint begin = _begin(list, cur);
	if (begin > point) {
	  break;
	}

	_intervalIDs[num] = uint(list.beginIndex.getNodeId(cur));
	num++;

	cur = _next(list, cur);
      }

      /*
       * search should proceed to earlier
       */
      searchNext = SEARCH_EARLIER;
    } else if (point > list.center) {
      /*
       * case: point is later than center.
       *
       *
       * collect matching intervals.
       *
       * shortcut:
       *
       *   starting with highest ending interval, search sorted end list
       *   until end is earlier than or equal to point
       *
       *			    point
       *			    :
       *                     center :
       *                       |    :
       *            *----------|----:-----o (0)
       *                   *---|----:-o     (1)
       *                     *-|----o	    (not matching, done.)
       *               *-------|---o	    (-)
       *                    *--|--o	    (-)
       *
       *
       *    this works because intervals contained in an interval list are
       *    guaranteed to contain `center`
       */
      cur = list.highestEnd;
      while (cur != 0x0) {
	uint end = _end(list, cur);
	if (end <= point) {
	  break;
	}

	_intervalIDs[num] = uint(list.endIndex.getNodeId(cur));
	num++;

	cur = _previous(list, cur);
      }

      /*
       * search proceeds to later intervals
       */
      searchNext = SEARCH_LATER;
    }

    /*
     * return correctly-sized array of intervalIDs
     */
    if (num == _intervalIDs.length) {
      intervalIDs = _intervalIDs;
    } else {
      intervalIDs = new uint[](num);
      for (uint i = 0; i < num; i++) {
	intervalIDs[i] = _intervalIDs[i];
      }
    }
  }

  /*
   * Grove linked list traversal
   */
  function _begin(List storage list, bytes32 indexNode) constant internal returns (uint) {
    return _getBegin(list.beginIndex.getNodeValue(indexNode));
  }

  function _end(List storage list, bytes32 indexNode) constant internal returns (uint) {
    return _getEnd(list.endIndex.getNodeValue(indexNode));
  }

  function _next(List storage list, bytes32 cur) constant internal returns (bytes32) {
    return list.beginIndex.getNextNode(cur);
  }

  function _previous(List storage list, bytes32 cur) constant internal returns (bytes32) {
    return list.endIndex.getPreviousNode(cur);
  }

  /*
   * uint / int conversions for Grove nodeIDs
   */
  function _getBeginIndexKey(uint begin) constant internal returns (int) {
    // convert to signed int in order-preserving manner
    return int(begin - 0x8000000000000000000000000000000000000000000000000000000000000000);
  }

  function _getEndIndexKey(uint end) constant internal returns (int) {
    // convert to signed int in order-preserving manner
    return int(end - 0x8000000000000000000000000000000000000000000000000000000000000000);
  }

  function _getBegin(int beginIndexKey) constant internal returns (uint) {
    // convert to unsigned int in order-preserving manner
    return uint(beginIndexKey) + 0x8000000000000000000000000000000000000000000000000000000000000000;
  }

  function _getEnd(int endIndexKey) constant internal returns (uint) {
    // convert to unsigned int in order-preserving manner
    return uint(endIndexKey) + 0x8000000000000000000000000000000000000000000000000000000000000000;
  }
}
