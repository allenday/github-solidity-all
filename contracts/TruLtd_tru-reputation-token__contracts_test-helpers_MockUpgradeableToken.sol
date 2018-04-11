pragma solidity ^0.4.18;
import "../supporting/TruUpgradeableToken.sol";


contract MockUpgradeableToken is TruUpgradeableToken {

  string public constant name = "Mock Upgradeable Token";
  string public constant symbol = "MUT";
  uint256 public constant decimals = 18;
  bool public upgradeable = false;

  function canUpgrade() public constant returns(bool) {
     return upgradeable;
  }

  function MockUpgradeableToken() TruUpgradeableToken(msg.sender) public {
    totalSupply = totalSupply.add(100);
  }

  function changeCanUpgrade(bool _newStatus) public {
    upgradeable = _newStatus;
  }
}