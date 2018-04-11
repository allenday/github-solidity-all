pragma solidity 0.4.11;

import '../controller/Controller.sol';
import "../SafeMath.sol";
import "../ERC20.sol";

contract PowerEvent {
  using SafeMath for uint;

  // states
  //   - waiting, initial state
  //   - collecting, after waiting, before collection stopped
  //   - failed, after collecting, if softcap missed
  //   - closed, after collecting, if softcap reached
  //   - complete, after closed or failed, when job done
  enum EventState { Waiting, Collecting, Closed, Failed, Complete }
  EventState public state;
  uint256 public RATE_FACTOR = 1000000;

  // Terms
  uint256 public startTime;
  uint256 public minDuration;
  uint256 public maxDuration;
  uint256 public softCap;
  uint256 public hardCap;
  uint256 public discountRate; // if rate 30%, this will be 300,000
  uint256 public amountPower;
  address[] public milestoneRecipients;
  uint256[] public milestoneShares;

  // Params
  address public controllerAddr;
  address public powerAddr;
  address public nutzAddr;
  uint256 public initialReserve;
  uint256 public initialSupply;

  function PowerEvent(address _controllerAddr, uint256 _startTime, uint256 _minDuration, uint256 _maxDuration, uint256 _softCap, uint256 _hardCap, uint256 _discount, uint256 _amountPower, address[] _milestoneRecipients, uint256[] _milestoneShares)
  areValidMileStones(_milestoneRecipients, _milestoneShares) {
    require(_minDuration <= _maxDuration);
    require(_softCap <= _hardCap);
    controllerAddr = _controllerAddr;
    startTime = _startTime;
    minDuration = _minDuration;
    maxDuration = _maxDuration;
    softCap = _softCap;
    hardCap = _hardCap;
    discountRate = _discount;
    amountPower = _amountPower;
    state = EventState.Waiting;
    milestoneRecipients = _milestoneRecipients;
    milestoneShares = _milestoneShares;
  }

  modifier isState(EventState _state) {
    require(state == _state);
    _;
  }

  modifier areValidMileStones(address[] _milestoneRecipients, uint256[] _milestoneShares) {
    require(checkMilestones(_milestoneRecipients, _milestoneShares));
    _;
  }

  function checkMilestones(address[] _milestoneRecipients, uint256[] _milestoneShares) internal returns (bool) {
    require(_milestoneRecipients.length == _milestoneShares.length && _milestoneShares.length <= 4);
    uint256 totalPercentage;
    for(uint8 i = 0; i < _milestoneShares.length; i++) {
      require(_milestoneShares[i] >= 0 && _milestoneShares[i] <= 1000000);
      totalPercentage = totalPercentage.add(_milestoneShares[i]);
    }
    require(totalPercentage >= 0 && totalPercentage <= 1000000);
    return true;
  }

  function tick() public {
    if (state == EventState.Waiting) {
      startCollection();
    } else if (state == EventState.Collecting) {
      stopCollection();
    } else if (state == EventState.Failed) {
      completeFailed();
    } else if (state == EventState.Closed) {
      completeClosed();
    } else {
      throw;
    }
  }

  function startCollection() isState(EventState.Waiting) {
    // check time
    require(now > startTime);
    // assert(now < startTime.add(minDuration));
    // read initial values
    var contr = Controller(controllerAddr);
    powerAddr = contr.powerAddr();
    nutzAddr = contr.nutzAddr();
    initialSupply = contr.activeSupply().add(contr.powerPool()).add(contr.burnPool());
    initialReserve = nutzAddr.balance;
    uint256 ceiling = contr.ceiling();
    // move ceiling
    uint256 newCeiling = ceiling.mul(discountRate).div(RATE_FACTOR);
    contr.moveCeiling(newCeiling);
    // set state
    state = EventState.Collecting;
  }

  function stopCollection() isState(EventState.Collecting) {
    uint256 collected = nutzAddr.balance.sub(initialReserve);
    if (now > startTime.add(maxDuration)) {
      if (collected >= softCap) {
        // softCap reached, close
        state = EventState.Closed;
        return;
      } else {
        // softCap missed, fail
        state = EventState.Failed;
        return;
      }
    } else if (now > startTime.add(minDuration)) {
      if (collected >= hardCap) {
        // hardCap reached, close
        state = EventState.Closed;
        return;
      } else {
        // keep going
        revert();
      }
    }
    // keep going
    revert();
  }

  function completeFailed() isState(EventState.Failed) {
    var contr = Controller(controllerAddr);
    // move floor (set ceiling or max floor)
    uint256 ceiling = contr.ceiling();
    contr.moveFloor(ceiling);
    // remove access
    contr.removeAdmin(address(this));
    // set state
    state = EventState.Complete;
  }

  function completeClosed() isState(EventState.Closed) {
    var contr = Controller(controllerAddr);
    // move ceiling
    uint256 ceiling = contr.ceiling();
    uint256 newCeiling = ceiling.mul(RATE_FACTOR).div(discountRate);
    contr.moveCeiling(newCeiling);
    // dilute power
    uint256 totalSupply = contr.activeSupply().add(contr.powerPool()).add(contr.burnPool());
    uint256 newSupply = totalSupply.sub(initialSupply);
    contr.dilutePower(newSupply, amountPower);
    // set max power
    var PowerContract = ERC20(powerAddr);
    uint256 authorizedPower = PowerContract.totalSupply();
    contr.setMaxPower(authorizedPower);
    // pay out milestone
    uint256 collected = nutzAddr.balance.sub(initialReserve);
    for (uint256 i = 0; i < milestoneRecipients.length; i++) {
      uint256 payoutAmount = collected.mul(milestoneShares[i]).div(RATE_FACTOR);
      contr.allocateEther(payoutAmount, milestoneRecipients[i]);
    }
    // remove access
    contr.removeAdmin(address(this));
    // set state
    state = EventState.Complete;
  }

}
