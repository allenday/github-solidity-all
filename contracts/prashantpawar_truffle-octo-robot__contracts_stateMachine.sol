pragma solidity ^0.4.2;

contract stateMachine {
  enum Stages {
    Negotiation, //Or Authoring or Pending Acceptance OR Approval
    Execution,
    Dispute,
    Resolution,
    AppealPeriod,
    Appeal,
    Completed
  }

  Stages public stage = Stages.Negotiation;

  modifier atStage(Stages _stage) {
    if (stage != _stage) throw;
    _;
  }

  modifier timedTransition(uint startTime, uint durationInDays, Stages _currStage, Stages _nextStage)
  {
    if (stage != _currStage) throw;
    if (now >= startTime + (durationInDays * 1 days))
        stage = _nextStage;
    _;
  }

  function nextStage() internal {
    stage = Stages(uint(stage) + 1);
  }
}

