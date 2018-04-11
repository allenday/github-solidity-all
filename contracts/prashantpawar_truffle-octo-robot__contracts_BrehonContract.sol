pragma solidity ^0.4.2;

import "./priced.sol";
import "./stateMachine.sol";
import "./accessRestricted.sol";

/// @title Brehon Contract
contract BrehonContract is
    priced,
    stateMachine,
    accessRestricted {

  struct Party {
    address addr;
    uint deposit;
    bool contractAccepted;
    bool primaryBrehonApproval;
    bool secondaryBrehonApproval;
    bool tertiaryBrehonApproval;
  }

  struct Brehon {
    address addr;
    bool contractAccepted;
    uint fixedFee;
    uint disputeFee;
  }

  int8 public appealLevel;
  uint public transactionAmount;
  Party public partyA;
  Party public partyB;
  Brehon public primaryBrehon;
  Brehon public secondaryBrehon;
  Brehon public tertiaryBrehon;
  Brehon public activeBrehon;

  mapping (address => uint) awards;

  uint appealPeriodInDays = 5;
  uint public appealPeriodStartTime;

  event ExecutionStarted(address _partyA, address _partyB, uint _totalDeposits);
  event ContractDisputed(address _disputingParty, address _activeBrehon);
  event AppealPeriodStarted(int8 _appealLevel, uint _startTime, address _activeBrehon, uint _awardPartyA, uint _awardPartyB);
  event AppealRaised(int8 _appealLevel, address _activeBrehon);

  modifier eitherByParty(Party _party1, Party _party2)
  {
    if (msg.sender != _party1.addr ||
        msg.sender != _party2.addr)
        throw;
    _;
  }

  modifier atDisputeStages()
  {
    if(stage != Stages.Dispute &&
       stage != Stages.Resolution &&
       stage != Stages.AppealPeriod &&
       stage != Stages.Appeal)
        throw;
    _;
  }

  modifier eitherByBrehon(Brehon _brehon1, Brehon _brehon2, Brehon _brehon3)
  {
    if (msg.sender != _brehon1.addr ||
        msg.sender != _brehon2.addr ||
        msg.sender != _brehon3.addr)
        throw;
    _;
  }

  modifier onlyByBrehon(Brehon _brehon) {
    if (msg.sender != _brehon.addr)
        throw;
    _;
  }

  function BrehonContract(
      address _partyA,
      address _partyB,
      uint _transactionAmount,
      address _primaryBrehon,
      uint _primaryBrehonFixedFee,
      uint _primaryBrehonDisputeFee,
      address _secondaryBrehon,
      uint _secondaryBrehonFixedFee,
      uint _secondaryBrehonDisputeFee,
      address _tertiaryBrehon,
      uint _tertiaryBrehonFixedFee,
      uint _tertiaryBrehonDisputeFee
  ) {
    partyA.addr = _partyA;
    transactionAmount = _transactionAmount;

    partyB.addr = _partyB;

    primaryBrehon.addr = _primaryBrehon;
    primaryBrehon.fixedFee = _primaryBrehonFixedFee;
    primaryBrehon.disputeFee = _primaryBrehonDisputeFee;

    secondaryBrehon.addr = _secondaryBrehon;
    secondaryBrehon.fixedFee = _secondaryBrehonFixedFee;
    secondaryBrehon.disputeFee = _secondaryBrehonDisputeFee;

    tertiaryBrehon.addr = _tertiaryBrehon;
    tertiaryBrehon.fixedFee = _tertiaryBrehonFixedFee;
    tertiaryBrehon.disputeFee = _tertiaryBrehonDisputeFee;

    //Defaults
    stage = Stages.Negotiation;
    appealLevel = -1;
    partyA.contractAccepted = false;
    partyA.primaryBrehonApproval = false;
    partyA.secondaryBrehonApproval = false;
    partyA.tertiaryBrehonApproval = false;
    partyA.deposit = 0;

    partyB.contractAccepted = false;
    partyB.primaryBrehonApproval = false;
    partyB.secondaryBrehonApproval = false;
    partyB.tertiaryBrehonApproval = false;
    partyB.deposit = 0;

    primaryBrehon.contractAccepted = false;
    secondaryBrehon.contractAccepted = false;
    tertiaryBrehon.contractAccepted = false;
  }

  function acceptContract()
    atStage(Stages.Negotiation)
    eitherByParty(partyA, partyB)
    eitherByBrehon(primaryBrehon, secondaryBrehon, tertiaryBrehon)
  {
      if (msg.sender == partyA.addr) {
          partyA.contractAccepted = true;
      } else if (msg.sender == partyB.addr) {
          partyB.contractAccepted = true;
      } else if(msg.sender == primaryBrehon.addr) {
          primaryBrehon.contractAccepted = true;
      } else if(msg.sender == secondaryBrehon.addr) {
          secondaryBrehon.contractAccepted = true;
      } else if(msg.sender == tertiaryBrehon.addr) {
          tertiaryBrehon.contractAccepted = true;
      } else throw;
  }

  function deposit()
    payable
    eitherByParty(partyA, partyB)
  {
      if(msg.sender == partyA.addr) {
          partyA.deposit += msg.value;
      } else if (msg.sender == partyB.addr) {
          partyB.deposit += msg.value;
      } else throw;
  }

  function startContract()
    atStage(Stages.Negotiation)
    eitherByParty(partyA, partyB)
  {
      if ((partyA.deposit + partyB.deposit) >
          (primaryBrehon.fixedFee + primaryBrehon.disputeFee +
          secondaryBrehon.fixedFee + secondaryBrehon.disputeFee +
          tertiaryBrehon.fixedFee + tertiaryBrehon.disputeFee) +
          transactionAmount
         ) {
             ExecutionStarted(partyA.addr, partyB.addr, partyA.deposit + partyB.deposit);
             stage = Stages.Execution;
      }
  }

  function raiseDispute()
    atStage(Stages.Execution)
    eitherByParty(partyA, partyB)
  {
    stage = Stages.Dispute;
    appealLevel = 0;
    activeBrehon = primaryBrehon;
    ContractDisputed(msg.sender, primaryBrehon.addr);
  }

  function adjudicate(uint _awardPartyA, uint _awardPartyB)
    atStage(Stages.Dispute)
    onlyByBrehon(activeBrehon)
  {
    stage = Stages.AppealPeriod;
    appealPeriodStartTime = now;

    awards[partyA.addr] = _awardPartyA;
    awards[partyB.addr] = _awardPartyB;
    
    AppealPeriodStarted(appealLevel, appealPeriodInDays, activeBrehon.addr, _awardPartyA, _awardPartyB);
  }

  function claimFunds()
    timedTransition(appealPeriodStartTime, appealPeriodInDays, Stages.AppealPeriod, Stages.Completed)
    atStage(Stages.Completed)
    eitherByParty(partyA, partyB)
    returns (bool)
  {
    uint amount = awards[msg.sender];
    awards[msg.sender] = 0;
    if(msg.sender.send(amount)) {
      return true;
    } else {
    awards[msg.sender] = amount;
      return false;
    }
  }

  function raiseAppeal()
    atStage(Stages.AppealPeriod)
    eitherByParty(partyA, partyB)
  {
    stage = Stages.Dispute;
    appealLevel = 1;

    activeBrehon = secondaryBrehon;

    AppealRaised(appealLevel, activeBrehon.addr);
  }

  function raise2ndAppeal()
    atStage(Stages.AppealPeriod)
    eitherByParty(partyA, partyB)
  {
    stage = Stages.Dispute;
    appealLevel = 2;

    activeBrehon = tertiaryBrehon;

    AppealRaised(appealLevel, activeBrehon.addr);
  }

  //Incomplete
  function proposeSettlement(uint _awardPartyA, uint _awardPartyB)
    atDisputeStages()
  {
      awards[partyA.addr] = _awardPartyA;
      awards[partyB.addr] = _awardPartyB;
  }

  function acceptSettlement() {
  }
}
