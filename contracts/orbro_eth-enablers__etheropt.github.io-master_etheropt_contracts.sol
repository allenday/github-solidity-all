contract EtheroptContracts {

  mapping(uint => address) contracts;
  mapping(uint => bool) statuses;
  mapping(address => uint) contractIDs; //starts at 1
  uint public numContracts = 0;

  function newContract(address addr) {
    if (msg.value>0) throw;
    numContracts++;
    contracts[numContracts] = addr;
    statuses[numContracts] = true;
    contractIDs[addr] = numContracts;
  }

  function getContracts() constant returns(address[]) {
    address[] memory addrs = new address[](20);
    uint z = 0;
    for (uint i=numContracts; i>0 && z<20; i--) {
      if (statuses[i] == true) {
        addrs[z] = contracts[i];
        z++;
      }
    }
    return addrs;
  }

  function disableContract(address addr) {
    if (msg.value>0) throw;
    statuses[contractIDs[addr]] = false;
  }

}
