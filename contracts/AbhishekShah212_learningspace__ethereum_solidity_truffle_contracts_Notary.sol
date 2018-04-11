pragma solidity ^0.4.4;

contract Notary {
  // state
  bytes32 public docHash;

  // calculate and store the docHash for a document
  function notarize(string document) {
    docHash = calculateProof(document);
  }

  // helper function to get a document's sha256
  // example of a constant function
  function calculateProof(string document) constant returns (bytes32) {
    return sha256(document);
  }
}
