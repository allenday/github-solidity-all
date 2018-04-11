pragma solidity ^0.4.15;

import "zeppelin-solidity/contracts/crowdsale/Crowdsale.sol";
import "./GorillaToken.sol";


/**
 * @title GorillaSale
 * @dev This is an example of a fully fledged crowdsale.
 * The way to add new features to a base crowdsale is by multiple inheritance.
 * In this example we are providing following extensions:
 * CappedCrowdsale - sets a max boundary for raised funds
 * RefundableCrowdsale - set a min goal to be reached and returns funds if it's not met
 *
 * After adding multiple features it's good practice to run integration tests
 * to ensure that subcontracts works together as intended.
 */
contract GorillaSale is Crowdsale {

  function GorillaSale(    uint256 _time_start,
                           uint256 _time_end,
                           uint256 _rate, 
                           address _wallet)

    Crowdsale(_time_start, _time_end, _rate, _wallet)
  {

  }

  function createTokenContract() internal returns (MintableToken) {
    return new GorillaToken();
  }

}
