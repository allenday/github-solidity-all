pragma solidity ^0.4.6;

contract AliasContract {
  mapping(bytes32 => address) public namesAddresses;

  function addAlias (bytes32 name, address ref) public {
    namesAddresses[name] = ref;
  }

  function getByAlias (bytes32 name) public returns (address) {
    return namesAddresses[name];
  }
}
