/**
 * This smart contract code is Copyright 2017 TokenMarket Ltd. For more information see https://tokenmarket.net
 *
 * Licensed under the Apache License, version 2.0: https://github.com/TokenMarketNet/ico/blob/master/LICENSE.txt
 *
 * Updated by Tru Ltd October 2017 to comply with Solidity 0.4.15 syntax and Best Practices
 */

pragma solidity ^0.4.18;

import "../supporting/UpgradeAgent.sol";
import "../supporting/TruMintableToken.sol";
import "../supporting/TruUpgradeableToken.sol";
import "../supporting/SafeMath.sol";
import "../TruReputationToken.sol";

/**
 * A sample token that is used as a migration testing target.
 *
 * This is not an actual token, but just a stub used in testing.
 */
contract MockMigrationTarget is TruReputationToken, UpgradeAgent {

  using SafeMath for uint;
  using SafeMath for uint256;

  TruUpgradeableToken public oldToken;

  uint public originalSupply;

  function MockMigrationTarget(TruUpgradeableToken _oldToken) public {
    oldToken = _oldToken;
    originalSupply = oldToken.totalSupply();
    require(originalSupply != 0);
  }

  function upgradeFrom(address _from, uint256 _value) public {

    // Mint new tokens to the migrator
    totalSupply = totalSupply.add(_value);
    balances[_from] = balances[_from].add(_value);
    Transfer(0, _from, _value);

  }

  function() public payable {
    revert();
  }

}