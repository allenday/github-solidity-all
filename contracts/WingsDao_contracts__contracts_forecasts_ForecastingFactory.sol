pragma solidity ^0.4.8;

import "./BasicForecasting.sol";

contract ForecastingFactory {
  address public token;

  function ForecastingFactory(address _token) {
    token = _token;
  }

  function create(
      address _timeManager,
      uint _rewardPercent,
      address _milestones,
      address _crowdsale
    ) public returns (address) {
      var forecasting = new BasicForecasting(
          _timeManager,
          _rewardPercent,
          token,
          _milestones,
          _crowdsale
        );

      return forecasting;
  }
}
