pragma solidity ^0.4.2;

contract PeerReview {
  uint public value;
  address public researcher;
  address public journal;
  enum State { Created, Approved, Declined }
  State public state;
  bytes public fileHash;

  function PeerReview(address initJournal, bytes initFileHash)
    payable
  {
    researcher = msg.sender;
    journal = initJournal;
    value = msg.value;
    state = State.Created;
    fileHash = initFileHash;
  }

  modifier inState(State _state) {
    if (state != _state) throw;
    _;
  }

  modifier onlyJournal() {
    if(msg.sender != journal) throw;
    _;
  }

  event peerReviewApproved();
  event peerReviewDeclined();

  function approve()
    onlyJournal
    inState(State.Created)
  {
    peerReviewApproved();

    // set state to approved
    state = State.Approved;

    // transfer all ether to journal
    if(!journal.send(this.balance)){
      throw;
    }
  }

  function decline()
    onlyJournal
    inState(State.Created)
  {
    peerReviewDeclined();

    // set state to declined
    state = State.Declined;

    // transfer all ether back to researcher
    if(!researcher.send(this.balance)){
      throw;
    }
  }
}
