pragma solidity ^0.4.7;

contract DredgrSwapOld {
  function DredgrSwap () {
    owner = msg.sender;
  }
  struct Swap {
    bytes5 outgoing;
    bytes5 incoming;
    bytes32 outgoing_from;
    bytes32 outgoing_to;
    bytes12 outgoing_amt;
    bytes32 incoming_from;
    bytes32 incoming_to;
    bytes12 incoming_amt;
  }
  address owner;
  mapping (uint => Swap) swaps;
  uint swapID;
  event swapCreated( 
    uint swapID
  );
  function addSwap (
    bytes5 _outgoing, 
    bytes5 _incoming,
    bytes32 _outgoing_from,
    bytes32 _outgoing_to,
    bytes12 _outgoing_amt,
    bytes32 _incoming_from,
    bytes32 _incoming_to,
    bytes12 _incoming_amt 
  ) {
    swapID++;
    swaps[swapID] = Swap(
      _outgoing,
      _incoming,
      _outgoing_from,
      _outgoing_to,
      _outgoing_amt,
      _incoming_from,
      _incoming_to,
      _incoming_amt 
    );
    swapCreated(swapID);
  }
  function getSwapOutgoing (uint swapID) constant returns(bytes32) {
    return(swaps[swapID].outgoing);
  }
}


