pragma solidity ^0.4.6;

contract Factory {
  bytes32[] public Names;
  address[] public newContracts;

  function createContract (bytes32 name) {
      address newContract = new Contract(name);
      newContracts.push(newContract);
  }

  function getName (uint i) {
      Contract con = Contract(newContracts[i]);
      Names[i] = con.Name();
  }
}

contract Contract {
  bytes32 public Name;

  function Contract (bytes32 name) {
    Name = name;
  }
}
