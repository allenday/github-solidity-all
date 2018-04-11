pragma solidity ^0.4.1;

import "ClinicalTrial.sol";

contract Regulator {

   address owner;
   int constant STATUS_SUBMITTED = 0;
   int constant STATUS_ACCEPTED  = 1;
   int constant STATUS_REJECTED  = 2;

   event ProposalSubmitted(address _submitter, bytes32 _drugName, uint _id);
   event ProposalAccepted (address _submitter, bytes32 _drugName, uint _id, address _clinicalTrial);
   event ProposalRejected (address _submitter, bytes32 _drugName, uint _id);

   struct CroIdentity {
      bytes32  name;
      bytes32  url;
      address addr;
      int   status;  //values: SUBMITTED, ACCEPTED, REJECTED
   }

   struct TrialProposal {
      address croAddr;
      bytes32  drugName;
      uint32  startDate;
      uint32  endDate;
      bytes  ipfsHash;
      int   status; // values: SUBMITTED, ACCEPTED, REJECTED
      address trial;  // clinical trial contract; 0x0 if none
   }

   CroIdentity   [] cros;
   TrialProposal [] proposals;

   modifier crosOnly {
      bool found = false;
      for(uint32 i=0; i<cros.length; i++) {
         if(cros[i].addr == msg.sender && cros[i].status == STATUS_ACCEPTED) {
            found = true;
            break;
         }
      }
      if(!found) throw;
      _;
   }

   modifier ownerOnly {
      if(msg.sender != owner) throw;
      _;
   }

   function Regulator() {
      owner = msg.sender;
   }

   function submitProposal(bytes32 _drugName, uint32 _startDate, uint32 _endDate) {

      TrialProposal memory proposal;
      proposal.croAddr   = msg.sender;
      proposal.drugName  = _drugName;
      proposal.startDate = _startDate;
      proposal.endDate   = _endDate;
      proposal.status    = STATUS_SUBMITTED;

      proposals.push(proposal);
   }

   function getProposalsCount() constant returns (uint _counter) {
      _counter = proposals.length;
   }

   function getProposalById(uint32 _id) constant returns(address _croAddr, bytes32 _drugName, uint32 _startDate, uint32 _endDate, bytes _ipfsHash, int _status, address _trial) {
      if(_id >= proposals.length) {
         return;
      }
      TrialProposal memory tp = proposals[_id];
      _croAddr = tp.croAddr;
      _drugName = tp.drugName;
      _startDate = tp.startDate;
      _endDate = tp.endDate;
      _ipfsHash = tp.ipfsHash;
      _status = tp.status;
      _trial = tp.trial;
   }

   function acceptProposal(uint _id) {

      if(_id >= proposals.length) {
         throw;
      }

      TrialProposal memory tp = proposals[_id];
      if(tp.status == STATUS_ACCEPTED) {
         throw;
      }

      // deploy the actual clinical trial contract and return it
      ClinicalTrial trial = new ClinicalTrial(owner, tp.croAddr, _id, tp.startDate, tp.endDate, tp.drugName, tp.ipfsHash);

      proposals[_id].trial = trial;
      proposals[_id].status = STATUS_ACCEPTED;

      ProposalAccepted (tp.croAddr, tp.drugName, _id, trial);
   }

   function rejectProposal(uint _id) {

      if(_id >= proposals.length) {
         throw;
      }

      proposals[_id].status = STATUS_REJECTED;

      TrialProposal memory tp = proposals[_id];
      ProposalRejected (tp.croAddr, tp.drugName, _id);
   }

   function submitCro(bytes32 _name, bytes32 _url) {
      CroIdentity memory cro;
      cro.name   = _name;
      cro.url    = _url;
      cro.addr   = msg.sender;
      cro.status = STATUS_SUBMITTED;

      cros.push(cro);
   }

   function changeCroStatus(address _addr, uint8 _status) {
      for(uint32 i=0; i<cros.length; i++) {
         if(cros[i].addr == _addr) {
            cros[i].status = _status;
            break;
         }
      }
   }

   function getCrosCounter() constant returns (uint _counter) {
      _counter = cros.length;
   }

   function getCroById(uint _id) constant returns(bytes32 _name, bytes32 _url, address _addr, int _status) {

      if(_id >= cros.length) {
         throw;
      }

      CroIdentity memory ci = cros[_id];
      _name = ci.name;
      _url  = ci.url;
      _addr = ci.addr;
      _status = ci.status;
   }

}
