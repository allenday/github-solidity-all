pragma solidity ^0.4.11;

import "./Counts.sol";

contract CountsCRUD {

  uint lastId;
  uint[] countsIds;
  mapping (uint => CountsStruct) countsMapping;
  mapping (bytes32 => uint) countsByName;
  struct CountsStruct {
    uint id;
    bytes32 partido;
    address countsAddress;
    uint index;
    bool isCounts;
  }

  function createCounts(bytes32 partido, address countsAddress) public {
    require(!existsCountsByName(partido));
    lastId += 1;
    countsMapping[lastId] = CountsStruct(lastId, partido, countsAddress, countsIds.length, true);
    countsByName[partido] = lastId;
    countsIds.push(lastId);
  }

  function getCountsById(uint id) public constant returns(address){
    require(existsCountsById(id));
    return countsMapping[id].countsAddress;
  }
  function getCountsByName(bytes32 name) public constant returns(address){
    require(countsByName[name] != 0);
    return getCountsById(countsByName[name]);
  }
  function existsCountsById(uint id) public constant returns(bool){
    return countsIds.length != 0 && countsMapping[id].isCounts;
  }
  function existsCountsByName(bytes32 name) public constant returns(bool){
    return countsByName[name] != 0 && existsCountsById(countsByName[name]);
  }
  function getAllCounts() public constant returns(uint[]){
    return countsIds;
  }

  function setData(bytes32 candidate, uint distritoId, uint escuelaId, uint mesaId, uint8[] result) public {
    require(existsCountsByName(candidate));
    Counts(getCountsByName(candidate)).setData(distritoId, escuelaId, mesaId, result);
  }


}
