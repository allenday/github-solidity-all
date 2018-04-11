//pragma solidity ^0.4.2;

contract Market {

  struct Node {
    bytes32 ident;
    bytes32 state; //online, master, worker, offline
    bytes32 ipaddress;
    bytes32 dappIdent;
    address coinbase;
  }

  mapping (bytes32 => Node) public nodes;
  bytes32[2**20] public nodeList;
  uint32 public numNodes;

  //Parameters should be fields in the struct, then add it to the nodeList
  function createNode(bytes32 ident, bytes32 state, bytes32 ipaddress) {
    nodes[ident] = Node({ident: ident, state: state, ipaddress: ipaddress, dappIdent:"", coinbase:msg.sender});
    nodeList[numNodes] = ident;
    numNodes += 1;
  }

  //TODO if there is time
  /*
  function removeNode() {
    // Remove node from list?
    // Remember to call penalizeNode if their state says that they are in the middle of an
    // application.
  }

  function penalizeNode(){
    //Penalize node if state of application isn't finished
    //Parameters: Something like address/hash, and then the amount penalized?
  }

  function setState(bytes32 name, bytes32 state) {
    nodes[name].state = state;
  }
  //we probably don't need that
  function setIPAddress(bytes32 name, bytes32 ipaddress) {
    nodes[name].ipaddress = ipaddress;
  }
  */

  struct DApp {
    bytes32 ident;
    bytes32 master;
    uint32 fee;
    address coinbase;
    bytes32 state;
    bytes ipfsHash;
    bytes32 class;
  }

  //Vars
  mapping (bytes32 => DApp) public dapps;
  bytes32[2**10] public dappList;
  uint32 public numDApps;
  mapping(bytes32 => bytes32[]) public workers;

  //	Parameter should be the driver nodes, amount of ethereum in escrow, escrow address
  //	(in the future, add the size of ddapp, memory needed, etc) to determine the
  //	most efficient processing.
  function createDApp(bytes32 ident, uint32 fee, bytes ipfsHash, bytes32 class) {
    if(numNodes == 0)
    return;

    bytes32 masterNodeIdent;
    bool masterFound;
    for(uint i =0; i < numNodes; i++) {
      Node masterNode = nodes[nodeList[i]];
      if (masterNode.state == "online") {
        masterNode.state = "master";
        masterNode.dappIdent = ident;
        masterFound = true;
        masterNodeIdent = masterNode.ident;
        break;
      }
    }

    if(!masterFound)
    return;

    for(i =0; i < numNodes && i < 5; i++) { //TODO: Get a better way of limiting nodes
      Node worker = nodes[nodeList[i]];
      if (worker.state == "online") {
        worker.state = "worker";
        worker.dappIdent = ident;
        workers[ident].push(worker.ident);
      }
    }

    dapps[ident]= DApp({master:masterNodeIdent, ident:ident, fee:fee, coinbase:msg.sender, state:"off", ipfsHash:ipfsHash, class:class});
    dappList[numDApps] = ident;
    numDApps += 1;

    //DDAP is not started a this point
  }

  function startDApp(bytes32 ident) {
    if(dapps[ident].coinbase == msg.sender)
    dapps[ident].state = "start";
  }


  //TODO: write payNode tests
  function payNode(bytes32 nodeIdent, uint32 operations){
    if(nodes[nodeIdent].ident == nodeIdent && nodes[nodeIdent].coinbase == msg.sender) {
      if(!nodes[nodeIdent].coinbase.send(dapps[nodes[nodeIdent].dappIdent].fee*operations))
      throw;
    }
  }

  //TODO: write more test cases?
  function finishDApp(bytes32 ident) {
    if(dapps[ident].coinbase != msg.sender)
    return;

    nodes[dapps[ident].master].state = "online";
    delete nodes[dapps[ident].master].dappIdent;

    for(var i =0; i < workers[ident].length; i++) {
      nodes[workers[ident][i]].state = "online";
      nodes[workers[ident][i]].dappIdent = "";
    }

    delete dapps[ident];
  }
}