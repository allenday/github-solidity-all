pragma solidity ^0.4.2;

import "./RVRControlled.sol";

contract Case is RVRControlled {

   uint start = 1;

   struct CaseStruct {
      uint id;
      address lawyer;
      uint index;
      uint progress;
   }

   mapping(uint => CaseStruct) private caseStructs;
   uint[] private caseIndex;

   event LogNewCase   (uint indexed caseId, uint index);
   event LogUpdateCase(uint indexed caseId, uint index);
   event LogDeleteCase(uint indexed caseId, uint index);

   function isCase(uint caseId) public constant returns(bool isIndeed) {
      if(caseIndex.length == 0) return false;
      return caseStructs[caseId].index >= 0;
   }

   function insertCase(uint caseId) public {
      caseIndex.push(caseId);
      caseStructs[caseId].id       = caseId;
      caseStructs[caseId].lawyer   = msg.sender;
      caseStructs[caseId].index    = caseIndex.length-1;
      caseStructs[caseId].progress = start;
   }

   function deleteCase(uint caseId) public {
      uint rowToDelete             = caseStructs[caseId].index;
      uint keyToMove            = caseIndex[caseIndex.length-1];
      caseIndex[rowToDelete]       = keyToMove;
      caseStructs[keyToMove].index = rowToDelete;
      caseIndex.length--;
   }

   function getCase(uint caseId) public constant returns(uint id, address lawyer, uint index, uint progress) {
      return(caseStructs[caseId].id, caseStructs[caseId].lawyer,
        caseStructs[caseId].index, caseStructs[caseId].progress);
   }

   function updateLawyer(uint caseId, address lawyer) public returns(bool success) {
      caseStructs[caseId].lawyer = lawyer;
      LogUpdateCase(caseId,caseStructs[caseId].index);
      return true;
   }

   function updateProgress(uint caseId, uint progress) public returns(bool success) {
      caseStructs[caseId].progress = progress;
      return true;
   }

   function getProgress(uint caseId) public constant returns(uint caseProgress) {
      return caseStructs[caseId].progress;
   }

   function getCaseCount() public constant returns(uint count) {
      return caseIndex.length;
   }

   function getCaseAtIndex(uint index) public constant returns (uint caseId) {
      return caseIndex[index];
   }

   function getAllCases() public constant returns(uint[] allCases) {
      return caseIndex;
   }

}
