pragma solidity ^0.4.18;

import "../supporting/SafeMath.sol";
import "../supporting/UpgradeAgent.sol";
import "../supporting/TruMintableToken.sol";
import "../supporting/TruUpgradeableToken.sol";
import "../TruReputationToken.sol";


/**
 * A sample token that is used as a migration testing target.
 *
 * This is not an actual token, but just a stub used in testing.
 */
contract MockUpgradeAgent is TruReputationToken, UpgradeAgent {

  using SafeMath for uint;

  TruUpgradeableToken public oldToken;

  uint public originalSupply;

  function isUpgradeAgent() public pure returns (bool) {
    return false;
  }

  function MockUpgradeAgent(TruUpgradeableToken _oldToken) public {
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