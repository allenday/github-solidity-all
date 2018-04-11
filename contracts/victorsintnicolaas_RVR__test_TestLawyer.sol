pragma solidity ^0.4.8;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/Lawyer.sol";

contract TestLawyer {

  address testAccount = 0xd05d276b7ce7c0cd1b3fb74d83705e2d3b46c62d;
  address testAccount2 = 0x2f9af4db3a4ec61a8ff468cc9d7b80fa62301673;

  struct LawyerStruct {
     uint id;
     uint index;
     uint caseId;
  }

  function testConstructorUsingDeployedContract() {
    Lawyer lawyer = Lawyer(DeployedAddresses.Lawyer());
    LawyerStruct memory expected = LawyerStruct(0, 0, 42); //Memory pointer instead of storage
    uint newId;
    uint newIndex;
    uint caseId;
    (newId, newIndex, caseId) = lawyer.getLawyer(testAccount);
    Assert.equal(0, caseId, "Unassigned lawyer should be empty");
  }

  function testInsertLawyer() {
    Lawyer lawyer = Lawyer(DeployedAddresses.Lawyer());
    LawyerStruct memory expected = LawyerStruct(42, 0, 42);
    lawyer.insertLawyer(testAccount, 42);
    uint newId;
    uint newIndex;
    uint caseId;
    (newId, newIndex, caseId) = lawyer.getLawyer(testAccount);

    Assert.equal(newId, expected.id, "Lawyer should have an id");
    Assert.equal(newIndex, expected.index, "Lawyer should have an index");
  }

  /*function testIsLawyer() {
    Lawyer lawyer = Lawyer(DeployedAddresses.Lawyer());
    bool expected = true;
    lawyer.insertLawyer(testAccount, "Han Solo", 42);

    Assert.equal(lawyer.isLawyer(testAccount), expected, "Lawyer should exist");
  }*/

  function testDeleteLawyer() {
    Lawyer lawyer = Lawyer(DeployedAddresses.Lawyer());
    uint expected = 1;
    lawyer.insertLawyer(testAccount, 42);
    lawyer.insertLawyer(testAccount2, 43);
    lawyer.deleteLawyer(testAccount2);

    Assert.equal(0, expected, "Lawyer should be deleted");
  }

  function testUpdateCase() {
    Lawyer lawyer = Lawyer(DeployedAddresses.Lawyer());
    LawyerStruct memory expected = LawyerStruct(42, 0, 42);
    lawyer.insertLawyer(testAccount, 42);
    lawyer.updateCase(testAccount, 42);
    uint newId;
    uint newIndex;
    uint caseId;
    (newId, newIndex, caseId) = lawyer.getLawyer(testAccount);

    Assert.equal(caseId, expected.caseId, "Lawyer should have an case");
  }

  function testGetLawyerCount() {
    Lawyer lawyer = Lawyer(DeployedAddresses.Lawyer());
    uint expected = 2;
    lawyer.insertLawyer(testAccount, 42);
    lawyer.insertLawyer(testAccount2, 43);

    Assert.equal(lawyer.getLawyerCount(), expected, "Lawyers should be counted");
  }

  function testGetLawyerAtIndex() {
    Lawyer lawyer = Lawyer(DeployedAddresses.Lawyer());
    address expected = testAccount2;
    lawyer.insertLawyer(testAccount, 42);
    lawyer.insertLawyer(testAccount2, 43);

    Assert.equal(lawyer.getLawyerAtIndex(1), expected, "Lawyer should be in list");
  }

  /*function testGetAllLawyers() {
    It is not possible to retrieve dynamic arrays in solidity, but it should work for web3.
  }*/

}
