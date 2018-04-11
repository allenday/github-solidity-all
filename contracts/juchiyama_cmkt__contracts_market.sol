pragma solidity ^0.4.0;
import {Node} from "node.sol";

contract Market is Node{
  
  function Market(bytes _ipfsHash,uint _maxVendors){
    /* set owner to sender/creator */
    owner       = msg.sender;
    /* set vendor max */
    maxLinks    = _maxVendors;
    /* set the ipfs ipfsHash */
    ipfsHash    = _ipfsHash;
    /* vendorCount 0 */
    linkCount   = 0;
  }

}
