pragma solidity ^0.4.0;
import {Node} from "node.sol";

contract Vendor is Node{

  function Vendor(bytes _ipfsHash,uint _subscriptionMax){
    /* set the owner to the sender */
    owner     = msg.sender;
    /* gas imposes hash limit */
    maxLinks  = _subscriptionMax;
    /* set the vendor ipfs root hash */
    ipfsHash  = _ipfsHash;
    /* set the n-subscriptions max */
    linkCount = 0;
  }

}
