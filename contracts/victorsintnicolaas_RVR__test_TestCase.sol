pragma solidity ^0.4.8;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/Case.sol";

contract TestCase {

  address testAccount = 0xd05d276b7ce7c0cd1b3fb74d83705e2d3b46c62d;
  address testAccount2 = 0x2f9af4db3a4ec61a8ff468cc9d7b80fa62301673;
  address testAccount3 = 0xe54b3840bac453b1eff171f6d9c0107458f307ca;

  struct CaseStruct {
     uint id;
     address lawyer;
     uint index;
     uint8 progress;
  }

  function testConstructorUsingDeployedContract() {
    Case caseDB = Case(DeployedAddresses.Case());
    CaseStruct memory expected = CaseStruct(0, address(0x0), 0, 0);

    Assert.equal(0, expected.id, "Unassigned case should be empty");
  }

  function testInsertCase() {
    Case caseDB = Case(DeployedAddresses.Case());
    CaseStruct memory expected = CaseStruct(42, this, 0, 0);
    caseDB.insertCase(42);
    uint newId;
    address newLawyer;
    uint newIndex;
    uint8 newProgress;
    (newId, newLawyer, newIndex, newProgress) = caseDB.getCase(42);

    Assert.equal(newId, expected.id, "Case should have an id");
    Assert.equal(newLawyer, expected.lawyer, "Case should have a Lawyer");
  }

  /*function testIsCase() {
    Case caseDB = Case(DeployedAddresses.Case());
    bool expected = true;
    caseDB.insertCase(testAccount2, 42);

    Assert.equal(caseDB.isCase(testAccount2), expected, "Case should exist");
  }*/

  function testDeleteCase() {
    Case caseDB = Case(DeployedAddresses.Case());
    uint expected = 1;
    caseDB.insertCase(42);
    caseDB.insertCase(43);
    caseDB.deleteCase(43);

    Assert.equal(1, expected, "Case should be deleted");
  }

  function testUpdateLawyer() {
    Case caseDB = Case(DeployedAddresses.Case());
    CaseStruct memory expected = CaseStruct(42, testAccount3, 0, 0);
    caseDB.insertCase(42);
    caseDB.updateLawyer(42, testAccount3);
    uint newId;
    address newLawyer;
    uint newIndex;
    uint8 newProgress;
    (newId, newLawyer, newIndex, newProgress) = caseDB.getCase(42);

    Assert.equal(newLawyer, expected.lawyer, "Lawyer should have changed");
  }

  function testUpdateProgress() {
    Case caseDB = Case(DeployedAddresses.Case());
    CaseStruct memory expected = CaseStruct(42, this, 0, 2);
    caseDB.insertCase(42);
    caseDB.updateProgress(42, 2);
    uint newId;
    address newLawyer;
    uint newIndex;
    uint8 newProgress;
    (newId, newLawyer, newIndex, newProgress) = caseDB.getCase(42);

    /*Assert.equal(newProgress, expected.progress, "Case should have progressed");*/
  }

  function testGetProgress() {
    Case caseDB = Case(DeployedAddresses.Case());
    CaseStruct memory expected = CaseStruct(42, this, 0, 2);
    caseDB.insertCase(42);
    caseDB.updateProgress(42, 2);

    /*Assert.equal(caseDB.getProgress(42), expected.progress, "Case should have progressed");*/
  }

  function testGetCaseCount() {
    Case caseDB = Case(DeployedAddresses.Case());
    uint expected = 2;
    caseDB.insertCase(42);
    caseDB.insertCase(43);

    Assert.equal(caseDB.getCaseCount(), expected, "Cases should be counted");
  }

  function testGetCaseAtIndex() {
    Case caseDB = Case(DeployedAddresses.Case());
    address expected = testAccount3;
    caseDB.insertCase(42);
    caseDB.insertCase(43);

    /*Assert.equal(caseDB.getCaseAtIndex(1), expected, "Cases should be in list");*/
  }

  /*function testGetAllCases() {
    It is not possible to retrieve dynamic arrays in solidity, but it should work for web3.
  }*/

}
