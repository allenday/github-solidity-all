pragma solidity ^0.4.8;

contract stateMachine {
  enum Stages {
    Negotiation, //Or Authoring or Pending Acceptance OR Approval
    Execution,
    Dispute,
    Resolved,
    AppealPeriod,
    Appeal,
    SecondAppealPeriod,
    SecondAppeal,
    Completed
  }

  Stages public stage = Stages.Negotiation;

  modifier atStage(Stages _stage) {
    if (stage != _stage) throw;
    _;
  }

  modifier timedTransition(bool bypassWaitTime, uint startTime, uint8 durationInDays, Stages _currStage, Stages _nextStage)
  {
    if (stage != _nextStage) {
        if (stage != _currStage) throw;
        if (bypassWaitTime || now >= startTime + (durationInDays * 1 days))
            stage = _nextStage;
    }
    _;
  }

  function nextStage() internal {
    stage = Stages(uint(stage) + 1);
  }
}

