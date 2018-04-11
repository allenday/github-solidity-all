pragma solidity ^0.4.11;


/// @title Role Based Access Control
contract RBAC {
  address owner;

  mapping (address => bool) admins;
  mapping (address => bool) inspectors;
  mapping (address => bool) farmers;
  mapping (address => bool) cantonEmployees;

  function RBAC(){
    owner = msg.sender;
  }

  function addFarmer(address farmerAddress){
    require(tx.origin == owner);
    farmers[farmerAddress] = true;
  }

  function isFarmer(address farmerAddress) constant returns (bool) {
    return farmers[farmerAddress];
  }

  function removeFarmer(address farmerAddress) {
    require(tx.origin == owner);
    delete farmers[farmerAddress];
  }

  function addAdmin(address adminAddress){
    require(tx.origin == owner);
    admins[adminAddress] = true;
  }

  function isAdmin(address adminAddress) constant returns (bool) {
    return admins[adminAddress];
  }

  function removeAdmin(address adminAddress) {
    require(tx.origin == owner);
    delete admins[adminAddress];
  }

  function addInspector(address inspectorAddress){
    require(tx.origin == owner);
    inspectors[inspectorAddress] = true;
  }

  function isInspector(address inspectorAddress) constant returns (bool) {
    return inspectors[inspectorAddress];
  }

  function removeInspector(address inspectorAddress) {
    require(tx.origin == owner);
    delete inspectors[inspectorAddress];
  }

  function addCantonEmployee(address cantonEmployeeAddress){
    require(tx.origin == owner);
    cantonEmployees[cantonEmployeeAddress] = true;
  }

  function isCantonEmployee(address cantonEmployeeAddress) constant returns (bool) {
    return cantonEmployees[cantonEmployeeAddress];
  }

  function removecantonEmployee(address cantonEmployeeAddress) {
    require(tx.origin == owner);
    delete cantonEmployees[cantonEmployeeAddress];
  }
}