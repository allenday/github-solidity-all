pragma solidity ^0.4.0;

contract Node{

  /* where is the node in ipfs */
  bytes public ipfsHash;

  /* Node owner */
  address public owner;

  enum NodeTypes { Market, Vendor, Subscription, Service }
  
  struct Link{
    address   owner;
    bytes     ipfsHash;
    NodeTypes nodeType;
  }
  
  /* link-contract => link */
  mapping(address => Link) links;

  /* gas imposes practical limits, how many links can we have */
  uint public maxLinks;

  /* gas imposes practical limits, link count */
  uint public linkCount;

  function getLinkOwner(address node) constant returns (address){
    return links[node].owner;
  }

  function getLinkHash(address node) constant returns (bytes){
    return links[node].ipfsHash;
  }

  function getNodeType(address node) constant returns (NodeTypes){
    return links[node].nodeType;
  }

  event NodeIPFSHashUpdate(bytes ipfsHash);
  event LinkCountUpdate(uint linkCount);
  event NodeUpdateRequest(bytes ipfsHash,bytes fromLinkIPFSHash,bytes toLinkIPFSHash);
  
  function addLink(address linkNode,address linkNodeOwner,bytes linkNodeIPFS,bytes nodeIPFS,NodeTypes linkType) returns (bool){
    /* sender is owner && linkCount okay && linkNode does not yet exist, linkNodeIPFS exists, nodeIPFS exists */
    if ( msg.sender == owner && maxLinks > linkCount && links[linkNode].owner == address(0x0) && linkNodeIPFS.length > 0 && nodeIPFS.length > 0) {
      /* create a new link */
      links[linkNode]        = Link(linkNodeOwner,linkNodeIPFS,linkType);
      /* bump linkCount */
      linkCount            = linkCount   + 1;
      /* set the new IPFS hash */
      ipfsHash             = nodeIPFS;
      /* emit hash update and link count update */
      NodeIPFSHashUpdate(nodeIPFS);
      LinkCountUpdate(linkCount);
    } else {
      throw;
    }
  }

  /* linkNode is the node to remove, nodeIPFS is the updated node-ipfs-pointer */
  function removeLink(address linkNode,bytes nodeIPFS) returns (bool){
    /* sender is owner, linkNode exists, and input ipfsHash exists */
    if ( msg.sender == owner && links[linkNode].ipfsHash.length > 0 && nodeIPFS.length > 0){
      // delete record of existence
      delete links[linkNode];
      linkCount = linkCount - 1;
      ipfsHash  = nodeIPFS;
      NodeIPFSHashUpdate(ipfsHash);
      LinkCountUpdate(linkCount);
      return true;
    } else {
      throw;
    }
  }

  /* Updating a link can only be done by the owner */
  function updateLink(address linkNode,bytes linkNodeIPFS) returns (bool){
    /* sender must owner of the node and nodeIPFS must exist */
    if ( links[linkNode].owner == msg.sender && linkNodeIPFS.length > 0 ){
      bytes previous           = links[linkNode].ipfsHash;
      links[linkNode].ipfsHash = linkNodeIPFS;
      // UPDATING a parent node is done by the owner
      NodeUpdateRequest(ipfsHash,previous,linkNodeIPFS);
      return true;
    } else {
      throw;
    }
  }

  /* the MarketRootUpdateRequest accepts ipfsHash updates */
  function updateNodeIPFSHash(bytes nodeIPFS) returns (bool){
    /* sender must be owner and nodeIPFS must be a reasonable value */
    if ( msg.sender == owner && nodeIPFS.length > 0 ) {
      ipfsHash = nodeIPFS;
      NodeIPFSHashUpdate(nodeIPFS);
      return true;
    } else {
      throw;
    }
  }

  
}
