pragma solidity ^0.4.4;

contract TestContract is usingPSOraclize {

  string value;

  function TestContract(address oraclize) {
    __update_oraclize(oraclize);
    value = "Not initialized";
  }

  function result() constant returns (string) {
    return value;
  }

  function update() returns (bytes32 id) {
    return oraclize_query("http://checkip.amazonaws.com/");
  }

  function __callback(bytes32 myid, string result) {
    value = result;
  }
}
