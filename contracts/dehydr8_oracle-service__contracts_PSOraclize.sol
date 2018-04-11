pragma solidity ^0.4.4;

contract PSOraclize {
  // request count for callers
  mapping (address => uint) reqc;

  event Log(address sender, bytes32 cid, string arg);

  function query(string _arg) returns (bytes32 _id) {
    _id = sha3(this, msg.sender, reqc[msg.sender]);
    reqc[msg.sender]++;
    Log(msg.sender, _id, _arg);
    return _id;
  }
}
