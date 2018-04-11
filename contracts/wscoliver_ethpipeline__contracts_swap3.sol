pragma solidity ^0.4.7;

contract DredgrSwapSolo {
  bytes5 public outgoing;
  bytes5 public incoming;
  bytes32 public outgoing_from;
  bytes32 public outgoing_to;
  uint public outgoing_amt;
  bytes32 public incoming_from;
  bytes32 public incoming_to;
  uint public incoming_amt;
  address owner;
  event swapCreated( 
    uint swapID
  );
  function DredgrSwapSolo (
    bytes5 _outgoing, 
    bytes5 _incoming,
    bytes32 _outgoing_from,
    bytes32 _outgoing_to,
    uint _outgoing_amt,
    bytes32 _incoming_from,
    bytes32 _incoming_to,
    uint _incoming_amt 
  ) {
    outgoing = _outgoing;
    incoming = _incoming;
    outgoing_from = _outgoing_from;
    outgoing_to = _outgoing_to;
    outgoing_amt = _outgoing_amt;
    incoming_from = _incoming_from;
    incoming_to = _incoming_to;
    incoming_amt =  _incoming_amt;
    owner = msg.sender;
    swapCreated(1);
  }
}
