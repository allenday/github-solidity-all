//Throughout the contract arbitrators are zero indexed
contract arbitrated {
  address [] arbitrators;
  int8 currentArbitrator = -1; 

  address partyA;
  address partyB;

  bool isDisputed;
  modifier disputeLockable() {
    //If no arbitrator is set then don't let anyone execute the function 
    //OR if contract is disputed but the caller isn't the current arbitrator,
    //then prevent this method from being executed
    if((currentArbitrator < 0)
        || (partyA == 0x0 || partyB == 0x0)
        || (arbitrators.length < 3)
        || (isDisputed && msg.sender != arbitrators[uint(currentArbitrator)])) {
      throw;
    } 
  }

  function setArbitrator0(address addr) {
    arbitrators[0] = addr;
  }

  /**
   * Arbitrators 1 and 2 need to be set at once.
   * Also once they are set
   * **/
  function setArbitrator1and2(address addr1, address addr2) {
    if(arbitrators[0] == 0x0
        || addr1 == 0x0
        || addr2 == 0x0) {
        throw;
    }
    arbitrators[1] = addr1;
    arbitrators[2] = addr2;

    currentArbitrator = 0;
  }

  function setPartyA(address addr) {
    partyA = addr;
  }

  function setPartyB(address addr) {
    partyB = addr;
  }

  function raiseDispute() {
    if(msg.sender == partyA || msg.sender == partyB) {
        isDisputed = true;
    }
  }

} 
