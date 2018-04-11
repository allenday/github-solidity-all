// https://github.com/acloudfan/Blockchain-Course-Patterns/blob/master/test/contract_factory.js
// https://github.com/acloudfan/Blockchain-Course-Patterns/blob/master/contracts/ContractFactory.sol

pragma solidity ^0.4.4;

import "./Patient.sol";

contract PatientFactory {

  // Maps accounts to its respective Patient instance
  mapping(address => Patient) mMap;

  function PatientFactory() {
  }

  function MakePatient() {
    if (address(mMap[msg.sender]) == 0) {
      mMap[msg.sender] = new Patient(msg.sender);
    }
  }

  function DeletePatient() {
    delete mMap[msg.sender];
  }

  // Gets the address of the Patient instance associated with the caller
  function GetPatient() constant returns (Patient) {
    return mMap[msg.sender];
  }

  function IsPatient(address who) constant returns (bool) {
    return mMap[who] != address(0);
  }

  function GetPatientFromAddress(address who) constant returns (Patient) {
    return mMap[who];
  }

}
