pragma solidity ^0.4.8;

contract DataStore {
  string data;

  function DataStore(string _data) {
    data = _data;
  }

  function update(string _data) returns(bool sufficient) {
    // if (balances[msg.sender] < amount) return false;
    data = _data;
    return true;
  } 

  function getData() returns(string) {
    return data;
  }

}
