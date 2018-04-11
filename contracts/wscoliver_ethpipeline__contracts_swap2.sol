pragma solidity ^0.4.7;

contract DredgrSwap {
  function DredgrSwap () {
    owner = msg.sender;
  }
  address owner;
  mapping (uint => string) swaps;
  uint swapID;
  event swapCreated( 
    uint swapID
  );
  function addSwap (
    string _data 
  ) {
    swapID++;
    swaps[swapID] = _data;
    swapCreated(swapID);
  }
  function getSwap (uint swapID) constant returns(string) {
    return(swaps[swapID]);
  }
}


