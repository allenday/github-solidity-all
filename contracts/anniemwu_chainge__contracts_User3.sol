pragma solidity ^0.4.15;
contract User3 {
  // state
  bytes32[] private proofs;
  mapping(bytes32 => string) job_hash;

  // store a proof of existence in the contract state
  // *transactional function*
  function storeProof(bytes32 proof) {
    proofs.push(proof);
  }
// calculate and store the proof for a descriptor
  // *transactional function*
  function notarize(string descriptor) {
    bytes32 proof = proofFor(descriptor);
    job_hash[proof] = descriptor;
    storeProof(proof);
  }
// helper function to get a descriptor's sha256
  // *read-only function*
  function proofFor(string descriptor) constant returns (bytes32) {
    return sha256(descriptor);
  }
// check if a descriptor has been notarized
  // *read-only function*
  function checkString(string descriptor) constant returns (bool) {
    bytes32 proof = proofFor(descriptor);
    return hasProof(proof);
  }
  function findString(bytes32 proof) constant returns (string) {
    string result = job_hash[proof];
    return result;
  }
  // returns true if proof is stored
  // *read-only function*
  function hasProof(bytes32 proof) constant returns (bool) {
    for (uint256 i = 0; i < proofs.length; i++) {
      if (proofs[i] == proof) {
        return true;
      }
    }
    return false;
  }
}
