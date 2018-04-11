pragma solidity ^0.4.18;

import './common/StandardToken.sol';
import './common/SafeOwnable.sol';


contract PapyrusAirdrop is SafeOwnable {

  // PUBLIC FUNCTIONS

  function PapyrusAirdrop(address _token) public {
    require(_token != address(0));
    token = StandardToken(_token);
  }

  function airdrop(address[] receivers, uint256[] amounts) public onlyOwner {
    require(receivers.length == amounts.length);
    bool success = true;
    for (uint256 i = 0; i < receivers.length && success; ++i) {
      success = token.transfer(receivers[i], amounts[i]);
    }
    require(success);
  }

  // FIELDS

  StandardToken public token;
}
