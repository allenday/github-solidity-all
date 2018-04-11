pragma solidity ^0.4.2;

import "./RVRControlled.sol";

contract Lawyer is RVRControlled {

   struct LawyerStruct {
      uint id;
      uint index;
      uint caseId;
   }

   mapping(address => LawyerStruct) private lawyerStructs;
   address[] private lawyerIndex;

   event LogNewLawyer   (address indexed lawyerAddress, uint id);
   event LogUpdateLawyer(address indexed lawyerAddress, uint id, uint caseId);
   event LogDeleteLawyer(address indexed lawyerAddress, uint id);

   function insertLawyer(address lawyerAddress, uint lawyerId) public {
      lawyerIndex.push(lawyerAddress);
      lawyerStructs[lawyerAddress].id           = lawyerId;
      lawyerStructs[lawyerAddress].index        = lawyerIndex.length-1;
   }

   function deleteLawyer(address lawyerAddress) public {
      uint rowToDelete = lawyerStructs[lawyerAddress].index;
      address keyToMove = lawyerIndex[lawyerIndex.length-1];
      lawyerIndex[rowToDelete] = keyToMove;
      lawyerStructs[keyToMove].index = rowToDelete;
      lawyerIndex.length--;
   }

   function getLawyer(address lawyerAddress) public constant returns(uint id, uint index, uint caseId) {
      return(lawyerStructs[lawyerAddress].id, lawyerStructs[lawyerAddress].index, lawyerStructs[lawyerAddress].caseId);
   }

   function isLawyer(address lawyerAddress) public constant returns(bool isLawyer) {
      if(lawyerIndex.length == 0) {
        return false;
      } else {
        return lawyerStructs[lawyerAddress].index >= 0;
      }
   }

   function updateCase(address lawyerAddress, uint caseId) public constant returns(bool success) {
      LogUpdateLawyer(lawyerAddress,lawyerStructs[lawyerAddress].index, caseId);
      lawyerStructs[lawyerAddress].caseId = caseId;
      return true;
   }

   function getLawyerCount() public constant returns(uint count) {
      return lawyerIndex.length;
   }

   function getLawyerAtIndex(uint index) public constant returns (address lawyerAddress) {
      return lawyerIndex[index];
   }

   function getAllLawyers() public constant returns(address[] allLawyers) {
      return lawyerIndex;
   }

}
