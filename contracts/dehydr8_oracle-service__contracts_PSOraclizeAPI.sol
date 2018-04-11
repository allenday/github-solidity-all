pragma solidity ^0.4.4;

contract PSOraclizeI {
  function query(string _arg) returns (bytes32 _id);
}

contract usingPSOraclize {

  PSOraclizeI oraclize;

  function __update_oraclize(address _oraclizeAddress) {
    oraclize = PSOraclizeI(_oraclizeAddress);
  }

  function __callback(bytes32 myid, string result) {
  
  }

  function oraclize_query(string arg) returns (bytes32 id) {
    return oraclize.query(arg);
  }
}
