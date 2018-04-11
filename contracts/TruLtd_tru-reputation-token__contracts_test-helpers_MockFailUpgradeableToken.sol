pragma solidity ^0.4.18;
import "../supporting/TruUpgradeableToken.sol";


contract MockFailUpgradeableToken is TruUpgradeableToken {

  bool public upgradeable = false;
  string public constant name = "Mock Upgradeable Token";
  string public constant symbol = "MUT";
  uint256 public constant decimals = 18;

  function canUpgrade() public constant returns(bool) {
     return upgradeable;
  }

  function MockFailUpgradeableToken() TruUpgradeableToken(0x0) public {
    totalSupply = totalSupply.add(100);
  }

  function changeCanUpgrade(bool _newStatus) public {
    upgradeable = _newStatus;
  }
}