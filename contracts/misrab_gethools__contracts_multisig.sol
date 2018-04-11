contract multisig {
  address[] parties;
  address creator;
  uint N;
  uint required_accepts;
  uint accepted;
  uint total_wei;
  mapping (address => bool) parties_map;

  modifier isAnOwner() {
      if (parties_map[msg.sender]) { _ }
  }

  function multisig(address[] _parties, uint _required_accepts) {
    creator = msg.sender;
    parties = _parties;
    N = _parties.length;
    required_accepts = _required_accepts;

    if (required_accepts > N) { throw; }

    for (uint i=0; i < N; i++) {
        parties_map[parties[i]] = true;
    }


  }

  function() {
    total_wei += msg.value;
  }

  function accept() isAnOwner {
    accepted++;
  }

  function kill() isAnOwner {
     if (accepted < required_accepts) { throw; }

     uint _amount_each = total_wei / N;

     for (uint i=0; i < N; i++) {
        parties[i].send(_amount_each);
     }

     // in the unlikely case of spare change, it's send to the creator
     suicide(creator);
  }
}
