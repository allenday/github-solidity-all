pragma solidity ^0.4.4;

library HashLib {
  function matches(bytes32 doubleHash, bytes32 singleHash) returns (bool _matches) {
    return doubleHash == sha3(singleHash);
  }
}
