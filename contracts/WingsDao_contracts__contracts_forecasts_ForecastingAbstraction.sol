pragma solidity ^0.4.8;

import "../zeppelin/Ownable.sol";
import "../Token.sol";
import "../milestones/MilestonesAbstraction.sol";
import "../Temporary.sol";

contract ForecastingAbstraction is Ownable, Temporary {
  /*
    Allow 6 numbers after dot.
  */
  modifier isValidRewardPercent(uint _rewardPercent) {
    if (_rewardPercent > 100000000 || _rewardPercent == 0) {
      throw;
    }

    _;
  }

  struct Forecast {
    address owner;
    uint amount;
    uint created_at;
    bytes32 message;
  }

  mapping(uint => Forecast) public forecasts;
  mapping(address => Forecast) public userForecasts;

  /*
    Forecasts count
  */
  uint public forecastsCount;

  /*
    Reward forecasting percent
  */
  uint public rewardPercent;

  /*
    Token
  */
  Token public token;

  /*
    Milestones
  */
  MilestonesAbstraction public milestones;

  /*
    Crowdsale
  */
  address public crowdsale;

  /*
    Max forecast amount
  */
  uint public max;

  /*
    Add forecast
  */
  function add(uint _amount, bytes32 _message) inTime();

  /*
    Get user forecast
  */
  function getByUser(address _user) constant returns (uint, uint, bytes32);

  /*
    Get forecast
  */
  function get(uint _index) constant returns (address, uint, uint, bytes32);
}
