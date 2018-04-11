pragma solidity ^0.4.8;

import "./ForecastingAbstraction.sol";
import "../milestones/BasicMilestones.sol";

contract BasicForecasting is ForecastingAbstraction {
  event ADD_FORECAST(address indexed account, uint amount, address forecast);
  /*
    Lock tokens here in forecast contract?
  */
  function BasicForecasting(address _timeManager,
                            uint _rewardPercent,
                            address _token,
                            address _milestones,
                            address _crowdsale
                          ) isValidRewardPercent(_rewardPercent) {
    timeManager = _timeManager;
    rewardPercent = _rewardPercent;
    token = Token(_token);
    milestones = BasicMilestones(_milestones);
    crowdsale = _crowdsale;
  }

  /*
    Add forecast
    ToDo: We should check maximum amount of forecasting
  */
  function add(uint _amount, bytes32 _message) inTime() {
    if (milestones.cap() == true) {
        if (max == 0) {
          max = milestones.totalAmount();
        }

        if (max < _amount) {
          throw;
        }
    }

    /*
      Should allow us to lock Wings tokens.
    */
    if (userForecasts[msg.sender].owner != address(0)) {
      throw;
    }

    var forecast = Forecast(
      msg.sender,
      _amount,
      block.timestamp,
      _message
    );

    forecasts[forecastsCount++] = forecast;
    userForecasts[msg.sender] = forecast;

    ADD_FORECAST(msg.sender, _amount, address(this));
  }

  /*
    Get user forecast
  */
  function getByUser(address _user) constant returns (uint, uint, bytes32) {
    var forecast = userForecasts[_user];

    return (forecast.amount, forecast.created_at, forecast.message);
  }

  /*
    Get forecast
  */
  function get(uint _index) constant returns (address, uint, uint, bytes32) {
    var forecast = forecasts[_index];

    return (forecast.owner, forecast.amount, forecast.created_at, forecast.message);
  }
}
