pragma solidity 0.4.11;

import "../satelites/Power.sol";
import "./MarketEnabled.sol";

contract PowerEnabled is MarketEnabled {

  // satelite contract addresses
  address public powerAddr;

  // maxPower is a limit of total power that can be outstanding
  // maxPower has a valid value between outstandingPower and authorizedPow/2
  uint256 public maxPower = 0;

  // time it should take to power down
  uint256 public downtime;

  modifier onlyPower() {
    require(msg.sender == powerAddr);
    _;
  }

  function PowerEnabled(address _powerAddr, address _pullAddr, address _storageAddr, address _nutzAddr)
    MarketEnabled(_pullAddr, _nutzAddr, _storageAddr) {
    powerAddr = _powerAddr;
  }

  function setMaxPower(uint256 _maxPower) public onlyAdmins {
    require(outstandingPower() <= _maxPower && _maxPower < authorizedPower());
    maxPower = _maxPower;
  }

  function setDowntime(uint256 _downtime) public onlyAdmins {
    downtime = _downtime;
  }

  // this is called when NTZ are deposited into the burn pool
  function dilutePower(uint256 _amountBabz, uint256 _amountPower) public onlyAdmins {
    uint256 authorizedPow = authorizedPower();
    uint256 totalBabz = totalSupply();
    if (authorizedPow == 0) {
      // during the first capital increase, set value directly as authorized shares
      _setAuthorizedPower((_amountPower > 0) ? _amountPower : _amountBabz.add(totalBabz));
    } else {
      // in later increases, expand authorized shares at same rate like economy
      _setAuthorizedPower(authorizedPow.mul(totalBabz.add(_amountBabz)).div(totalBabz));
    }
    _setBurnPool(burnPool().add(_amountBabz));
  }

  function _slashPower(address _holder, uint256 _value, bytes32 _data) internal {
    uint256 previouslyOutstanding = outstandingPower();
    _setOutstandingPower(previouslyOutstanding.sub(_value));
    // adjust size of power pool
    uint256 powPool = powerPool();
    uint256 slashingBabz = _value.mul(powPool).div(previouslyOutstanding);
    _setPowerPool(powPool.sub(slashingBabz));
    // put event into satelite contract
    Power(powerAddr).slashPower(_holder, _value, _data);
  }

  function slashPower(address _holder, uint256 _value, bytes32 _data) public onlyAdmins {
    _setPowerBalanceOf(_holder, powerBalanceOf(_holder).sub(_value));
    _slashPower(_holder, _value, _data);
  }

  function slashDownRequest(uint256 _pos, address _holder, uint256 _value, bytes32 _data) public onlyAdmins {
    var (total, left, start) = downs(_holder);
    left = left.sub(_value);
    _setDownRequest(_holder, total, left, start);
    _slashPower(_holder, _value, _data);
  }

  // this is called when NTZ are deposited into the power pool
  function powerUp(address _sender, address _from, uint256 _amountBabz) public onlyNutz whenNotPaused {
    uint256 authorizedPow = authorizedPower();
    require(authorizedPow != 0);
    require(_amountBabz != 0);
    uint256 totalBabz = totalSupply();
    require(totalBabz != 0);
    uint256 amountPow = _amountBabz.mul(authorizedPow).div(totalBabz);
    // check pow limits
    uint256 outstandingPow = outstandingPower();
    require(outstandingPow.add(amountPow) <= maxPower);

    if (_sender != _from) {
      allowed[_from][_sender] = allowed[_from][_sender].sub(_amountBabz);
    }

    _setOutstandingPower(outstandingPow.add(amountPow));

    uint256 powBal = powerBalanceOf(_from).add(amountPow);
    require(powBal >= authorizedPow.div(10000)); // minShare = 10000
    _setPowerBalanceOf(_from, powBal);
    _setActiveSupply(activeSupply().sub(_amountBabz));
    _setBabzBalanceOf(_from, babzBalanceOf(_from).sub(_amountBabz));
    _setPowerPool(powerPool().add(_amountBabz));
    Power(powerAddr).powerUp(_from, amountPow);
  }

  function powerTotalSupply() constant returns (uint256) {
    uint256 issuedPower = authorizedPower().div(2);
    // return max of maxPower or issuedPower
    return maxPower >= issuedPower ? maxPower : issuedPower;
  }

  function _vestedDown(uint256 _total, uint256 _left, uint256 _start, uint256 _now) internal constant returns (uint256) {
    if (_now <= _start) {
      return 0;
    }
    // calculate amountVested
    // amountVested is amount that can be withdrawn according to time passed
    uint256 timePassed = _now.sub(_start);
    if (timePassed > downtime) {
     timePassed = downtime;
    }
    uint256 amountVested = _total.mul(timePassed).div(downtime);
    uint256 amountFrozen = _total.sub(amountVested);
    if (_left <= amountFrozen) {
      return 0;
    }
    return _left.sub(amountFrozen);
  }

  function createDownRequest(address _owner, uint256 _amountPower) public onlyPower whenNotPaused {
    // prevent powering down tiny amounts
    // when powering down, at least totalSupply/minShare Power should be claimed
    require(_amountPower >= authorizedPower().div(10000)); // minShare = 10000;
    _setPowerBalanceOf(_owner, powerBalanceOf(_owner).sub(_amountPower));

    var (, left, ) = downs(_owner);
    uint256 total = _amountPower.add(left);
    _setDownRequest(_owner, total, total, now);
  }

  // executes a powerdown request
  function downTick(address _holder, uint256 _now) public onlyPower whenNotPaused {
    var (total, left, start) = downs(_holder);
    uint256 amountPow = _vestedDown(total, left, start, _now);

    // prevent power down in tiny steps
    uint256 minStep = total.div(10);
    require(left <= minStep || minStep <= amountPow);

    // calculate token amount representing share of power
    uint256 amountBabz = amountPow.mul(totalSupply()).div(authorizedPower());

    // transfer power and tokens
    _setOutstandingPower(outstandingPower().sub(amountPow));
    left = left.sub(amountPow);
    _setPowerPool(powerPool().sub(amountBabz));
    _setActiveSupply(activeSupply().add(amountBabz));
    _setBabzBalanceOf(_holder, babzBalanceOf(_holder).add(amountBabz));
    // down request completed
    if (left == 0) {
      start = 0;
      total = 0;
    }
    // TODO
    _setDownRequest(_holder, total, left, start);
    Nutz(nutzAddr).powerDown(powerAddr, _holder, amountBabz);
  }
}
