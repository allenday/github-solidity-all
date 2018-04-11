pragma solidity ^0.4.15;

import "./IntervalLib.sol";
import "./ListLib.sol";

library TreeLib {
  using IntervalLib for IntervalLib.Interval;
  using ListLib for ListLib.List;
  // TODO: remove need for redefinition here
  uint8 constant SEARCH_DONE = 0x00;
  uint8 constant SEARCH_EARLIER = 0x01;
  uint8 constant SEARCH_LATER = 0x10;

  bool constant TRAVERSED_EARLIER = false;
  bool constant TRAVERSED_LATER = true;

  struct Tree {
    // global table of intervals
    mapping (uint => IntervalLib.Interval) intervals;
    uint numIntervals;

    // tree nodes
    mapping (uint => Node) nodes;
    uint numNodes;

    // pointer to root of tree
    uint rootNode;
  }

  struct Node {
    uint earlier;
    uint later;

    ListLib.List intervals;
  }

  /*
   * adding intervals
   */
  function addInterval(Tree storage tree,
		       uint begin,
		       uint end,
		       bytes32 data)
    internal
  {
    uint intervalID = _createInterval(tree, begin, end, data);

    // if the tree is empty, create the root
    if (tree.rootNode == 0) {
      var nodeID = _createNode(tree);
      tree.rootNode = nodeID;

      tree.nodes[nodeID].intervals.add(begin, end, intervalID);

      return;
    }

    /*
     * depth-first search tree for place to add interval.
     * for each step of the search:
     *   if the new interval contains the current node's center:
     *     add interval to current node
     *     stop search
     *
     *   if the new interval < center:
     *     recurse "before"
     *   if the new interval > center:
     *     recurse "after"
     */
    uint curID = tree.rootNode;

    bool found = false;
    do {
      Node storage curNode = tree.nodes[curID];


      // track direction of recursion each step, to update correct pointer
      // upon needing to add a new node
      bool recurseDirection;

      if (end <= curNode.intervals.center) {
	// traverse before
	curID = curNode.earlier;
	recurseDirection = TRAVERSED_EARLIER;
      } else if (begin > curNode.intervals.center) {
	// traverse after
	curID = curNode.later;
	recurseDirection = TRAVERSED_LATER;
      } else {
	// found!
	found = true;
	break;
      }

      // if traversing yields null pointer for child node, must create
      if (curID == 0) {
	curID = _createNode(tree);

	// update appropriate pointer
	if (recurseDirection == TRAVERSED_EARLIER) {
	  curNode.earlier = curID;
	} else {
	  curNode.later = curID;
	}

	// creating a new node means we've found the place to put the interval
	found = true;
      }
    } while (!found);

    tree.nodes[curID].intervals.add(begin, end, intervalID);
  }

  /*
   * retrieval
   */
  function getInterval(Tree storage tree, uint intervalID)
    constant
    internal
    returns (uint begin, uint end, bytes32 data)
  {
    require(intervalID > 0 && intervalID <= tree.numIntervals);

    var interval = tree.intervals[intervalID];
    return (interval.begin, interval.end, interval.data);
  }

  /*
   * searching
   */
  function search(Tree storage tree, uint point)
    constant
    internal
    returns (uint[] memory intervalIDs)
  {
    // can't search empty trees
    require(tree.rootNode != 0x0);

    // HACK repeatedly mallocs new arrays of matching interval IDs
    intervalIDs = new uint[](0);
    uint[] memory tempIDs;
    uint[] memory matchingIDs;
    uint i;  // for list copying loops

    /*
     * search traversal
     *
     * starting at root node
     */
    uint curID = tree.rootNode;
    uint8 searchNext;
    do {
      Node storage curNode = tree.nodes[curID];

      /*
       * search current node
       */
      (matchingIDs, searchNext) = curNode.intervals.matching(point);

      /*
       * add matching intervals to results array
       *
       * allocate temp array and copy in both prior and new matches
       */
      if (matchingIDs.length > 0) {
	tempIDs = new uint[](intervalIDs.length + matchingIDs.length);
	for (i = 0; i < intervalIDs.length; i++) {
	  tempIDs[i] = intervalIDs[i];
	}
	for (i = 0; i < matchingIDs.length; i++) {
	  tempIDs[i + intervalIDs.length] = matchingIDs[i];
	}
	intervalIDs = tempIDs;
      }

      /*
       * recurse according to node search results
       */
      if (searchNext == SEARCH_EARLIER) {
	curID = curNode.earlier;
      } else if (searchNext == SEARCH_LATER) { // SEARCH_LATER
	curID = curNode.later;
      }
    } while (searchNext != SEARCH_DONE && curID != 0x0);
  }


  /*
   * data create helpers helpers
   */
  function _createInterval(Tree storage tree, uint begin, uint end, bytes32 data)
    internal
    returns (uint intervalID)
  {
    intervalID = ++tree.numIntervals;

    tree.intervals[intervalID] = IntervalLib.Interval({
      begin: begin,
      end: end,
      data: data
    });
  }

  function _createNode(Tree storage tree) internal returns (uint nodeID) {
    nodeID = ++tree.numNodes;
    tree.nodes[nodeID] = Node({
      earlier: 0,
      later: 0,
      intervals: ListLib.createNew(nodeID)
    });
  }
}
