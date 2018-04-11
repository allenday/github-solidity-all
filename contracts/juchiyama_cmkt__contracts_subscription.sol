pragma solidity ^0.4.0;
import {Node} from "node.sol";

/* where in ipfs the subscription is located   TODO : DELETE THIS bytes public subscriptionRoot;*/

contract Subscription is Node{
  
  address public service;

  bytes public serviceRoot;
  
  function Subscription(bytes _ipfsHash,address _service,bytes _serviceRoot){
    /* set the owner to the sender */
    owner            = msg.sender;
    /* set the subscription location in ipfs */
    ipfsHash         = _ipfsHash;
    /* set the service contract address */
    service          = _service;
    /* set the ipfs serviceRoot */
    serviceRoot      = _serviceRoot;
  }

}

