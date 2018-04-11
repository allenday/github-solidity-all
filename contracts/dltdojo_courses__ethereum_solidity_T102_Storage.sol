pragma solidity ^0.4.14;

// 
// http://solidity.readthedocs.io/
// http://remix.ethereum.org/
//
// Bitcoin Block #1 https://blockchain.info/block/00000000839a8e6886ab5951d76f411475428afc90947ee320161bbf18eb6048
// Ethereum Block 1 Info https://etherscan.io/block/1
// 
contract Foo {
  uint storedData;
  function set(uint x) {
    storedData = x;
  }
}

// TODO
// Foo - Create
// Foo - set()