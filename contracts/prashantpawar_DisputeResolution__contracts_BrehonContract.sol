pragma solidity ^0.4.8;

import "./stateMachine.sol";
import "./accessRestricted.sol";

/// @title Brehon Contract
contract BrehonContract is
    stateMachine,
    accessRestricted {

  struct Party {
    address addr;
    uint deposit;
    bool contractAccepted;
  }

  struct Brehon {
    address addr;
    bool contractAccepted;
    uint fixedFee;
    uint disputeFee;
  }

  struct Resolution {
    address proposerAddr;
    uint awardPartyA;
    uint awardPartyB;
    bool partyAAccepted;
    bool partyBAccepted;
  }

  uint public transactionAmount;
  uint public minimumContractAmt;
  bytes32 public contractTermsHash;
  Party public partyA;
  Party public partyB;
  Brehon public primaryBrehon;
  Brehon public secondaryBrehon;
  Brehon public tertiaryBrehon;
  Brehon public activeBrehon;

  mapping (address => uint) public awards;
  Resolution public proposedSettlement;

  uint8 public appealPeriodInDays = 5;
  uint public appealPeriodStartTime;

  event ExecutionStarted(address caller, uint totalDeposits);
  event ContractDisputed(address disputingParty, address activeBrehon);
  event AppealPeriodStarted(uint appealPeriodStartTime, address activeBrehon, uint awardPartyA, uint awardPartyB);
  event AppealRaised(address appealingParty, address activeBrehon);
  event SecondAppealRaised(address appealingParty, address activeBrehon);
  event SettlementProposed(address proposingParty, uint awardPartyA, uint awardPartyB);
  event DisputeResolved(uint awardPartyA, uint awardPartyB);
  event FundsClaimed(address claimingParty, uint amount);

  modifier byEitherEntities() {
    if (msg.sender != primaryBrehon.addr &&
        msg.sender != secondaryBrehon.addr &&
        msg.sender != tertiaryBrehon.addr &&
        msg.sender != partyA.addr &&
        msg.sender != partyB.addr) {
        throw;
    }
    _;
  }

  modifier eitherByParty(Party _party1, Party _party2)
  {
    if (msg.sender != _party1.addr &&
        msg.sender != _party2.addr)
        throw;
    _;
  }

  modifier atAdjudicatableStages()
  {
    if(stage != Stages.Dispute &&
       stage != Stages.Appeal &&
       stage != Stages.SecondAppeal)
        throw;
    _;
  }

  modifier duringDispute()
  {
    if(stage == Stages.Negotiation ||
       stage == Stages.Completed)
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
      bytes32 _contractTermsHash,
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
    contractTermsHash = _contractTermsHash;

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

    minimumContractAmt = primaryBrehon.fixedFee + primaryBrehon.disputeFee +
        secondaryBrehon.fixedFee + secondaryBrehon.disputeFee +
        tertiaryBrehon.fixedFee + tertiaryBrehon.disputeFee +
        transactionAmount;

    //Defaults
    stage = Stages.Negotiation;
    partyA.contractAccepted = false;
    partyA.deposit = 0;

    partyB.contractAccepted = false;
    partyB.deposit = 0;

    primaryBrehon.contractAccepted = false;
    secondaryBrehon.contractAccepted = false;
    tertiaryBrehon.contractAccepted = false;
  }

  function acceptContract()
    atStage(Stages.Negotiation)
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
      if(!partyA.contractAccepted ||
         !partyB.contractAccepted ||
         !primaryBrehon.contractAccepted ||
         !secondaryBrehon.contractAccepted ||
         !tertiaryBrehon.contractAccepted) throw;

      if ((partyA.deposit + partyB.deposit) >=
          minimumContractAmt) {
             ExecutionStarted(msg.sender, partyA.deposit + partyB.deposit);
             stage = Stages.Execution; // STATECHANGE
             awards[primaryBrehon.addr] = primaryBrehon.fixedFee;
             awards[secondaryBrehon.addr] = secondaryBrehon.fixedFee;
             awards[tertiaryBrehon.addr] = tertiaryBrehon.fixedFee;
      } else throw;
  }

  function raiseDispute()
    atStage(Stages.Execution)
    eitherByParty(partyA, partyB)
  {
    stage = Stages.Dispute; // STATECHANGE
    awards[primaryBrehon.addr] += primaryBrehon.disputeFee;
    activeBrehon = primaryBrehon;
    ContractDisputed(msg.sender, primaryBrehon.addr);
  }

  function adjudicate(uint _awardPartyA, uint _awardPartyB)
    atAdjudicatableStages()
    onlyByBrehon(activeBrehon)
  {
    if((_awardPartyA + _awardPartyB) > (partyA.deposit + partyB.deposit)) throw;

    if (stage == Stages.Dispute) {
        stage = Stages.AppealPeriod; // STATECHANGE
    } else if (stage == Stages.Appeal) {
        stage = Stages.SecondAppealPeriod;  // STATECHANGE
    } else if (stage == Stages.SecondAppeal) {
        stage = Stages.Completed; // STATECHANGE
    } else {
        throw;
    }

    awards[partyA.addr] = _awardPartyA;
    awards[partyB.addr] = _awardPartyB;

    if (stage != Stages.Completed) {
        appealPeriodStartTime = now;

        AppealPeriodStarted(appealPeriodStartTime, activeBrehon.addr, _awardPartyA, _awardPartyB);
    } else {
        stage = Stages.Completed;
    }
  }

  function getActiveJudgmentByParty(address _partyAddress)
    returns (uint)
  {
      if(_partyAddress != partyA.addr &&
         _partyAddress != partyB.addr) throw;
    return awards[_partyAddress];
  }

  function claimFunds()
    byEitherEntities()
  {
    if (stage != Stages.Completed) {
        if (stage != Stages.AppealPeriod && stage != Stages.SecondAppealPeriod) {
            throw;
        }
        if (now >= appealPeriodStartTime + (appealPeriodInDays * 1 days)) {
            stage = Stages.Completed; // STATECHANGE
        }
    }

    if (stage != Stages.Completed) throw;

    uint amount = awards[msg.sender];

    if (amount == 0) {
      throw;
    }

    if (this.balance < amount) {
      throw;
    }

    awards[msg.sender] = 0;

    if(msg.sender.send(amount)) {
      FundsClaimed(msg.sender, amount);
    } else {
      awards[msg.sender] = amount;
      throw;
    }
  }

  function raiseAppeal()
    atStage(Stages.AppealPeriod)
    eitherByParty(partyA, partyB)
  {
    stage = Stages.Appeal; // STATECHANGE
    awards[secondaryBrehon.addr] += secondaryBrehon.disputeFee;

    activeBrehon = secondaryBrehon;

    AppealRaised(msg.sender, activeBrehon.addr);
  }

  function raise2ndAppeal()
    atStage(Stages.SecondAppealPeriod)
    eitherByParty(partyA, partyB)
  {
    stage = Stages.SecondAppeal; // STATECHANGE
    awards[tertiaryBrehon.addr] += tertiaryBrehon.disputeFee;

    activeBrehon = tertiaryBrehon;

    SecondAppealRaised(msg.sender, activeBrehon.addr);
  }

  function proposeSettlement(uint _awardPartyA, uint _awardPartyB)
    duringDispute()
    eitherByParty(partyA, partyB)
  {
      proposedSettlement.proposerAddr = msg.sender;
      proposedSettlement.awardPartyA = _awardPartyA;
      proposedSettlement.awardPartyB = _awardPartyB;
      if (msg.sender == partyA.addr) {
          proposedSettlement.partyAAccepted = true;
          proposedSettlement.partyBAccepted = false;
      } else if (msg.sender == partyB.addr) {
          proposedSettlement.partyAAccepted = false;
          proposedSettlement.partyBAccepted = true;
      }

      SettlementProposed(msg.sender, _awardPartyA, _awardPartyB);
  }

  function acceptSettlement(uint _awardPartyA, uint _awardPartyB)
    duringDispute()
    eitherByParty(partyA, partyB)
  {
      if((proposedSettlement.awardPartyA != _awardPartyA) ||
         (proposedSettlement.awardPartyB != _awardPartyB))
          throw;

      if(msg.sender == partyA.addr) {
          proposedSettlement.partyAAccepted = true;
      }

      if(msg.sender == partyB.addr) {
          proposedSettlement.partyBAccepted = true;
      }

      if(proposedSettlement.partyAAccepted && proposedSettlement.partyBAccepted) {
          awards[partyA.addr] = proposedSettlement.awardPartyA;
          awards[partyB.addr] = proposedSettlement.awardPartyB;
          stage = Stages.Completed; // STATECHANGE
          DisputeResolved(_awardPartyA, _awardPartyB);
      }
  }
}
