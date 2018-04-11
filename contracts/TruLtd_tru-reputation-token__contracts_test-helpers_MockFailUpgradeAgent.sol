pragma solidity ^0.4.18;

import "../supporting/SafeMath.sol";
import "../supporting/UpgradeAgent.sol";
import "../supporting/TruUpgradeableToken.sol";
import "../TruReputationToken.sol";

/**
 * A sample token that is used as a migration testing target.
 *
 * This is not an actual token, but just a stub used in testing.
 */
contract MockFailUpgradeAgent is UpgradeAgent, TruReputationToken {

    using SafeMath for uint;
    using SafeMath for uint256;

    TruUpgradeableToken public oldToken;

    function MockFailUpgradeAgent(TruUpgradeableToken _oldToken) public {
        oldToken = _oldToken;
        uint updatedSupply = oldToken.totalSupply();
        updatedSupply = updatedSupply.add(1000);
        originalSupply = updatedSupply;
        require(originalSupply > 0);
    }

    function isUpgradeAgent() public pure returns (bool) {
        return true;
    }

    function upgradeFrom(address _from, uint256 _value) public {

        // Mint new tokens to the migrator
        totalSupply = totalSupply.add(_value);
        balances[_from] = balances[_from].add(_value);
        Transfer(0, _from, _value);

    }

    function changeSupply() public returns (uint newSupply) {
        uint updatedSupply = originalSupply.add(1000);
        originalSupply = updatedSupply;
        return originalSupply;
    }

    function() public payable {
        revert();
    }
}