pragma solidity ^0.4.15;

import 'zeppelin-solidity/contracts/token/MintableToken.sol';
import 'zeppelin-solidity/contracts/token/LimitedTransferToken.sol';

/**
 * @title MyCrowdsaleToken
 */
contract MyCrowdsaleToken is MintableToken, LimitedTransferToken {

  string public constant name = "Sample Crowdsale Token";
  string public constant symbol = "SCT";
  uint8 public constant decimals = 18;
  bool public isTransferable = false;

  function enableTransfers() onlyOwner {
     isTransferable = true;
  }

  function transferableTokens(address holder, uint64 time) public constant returns (uint256) {
    if (!isTransferable) {
        return 0;
    }
    return super.transferableTokens(holder, time);
  }

  function finishMinting() onlyOwner public returns (bool) {
     enableTransfers();
     return super.finishMinting();
  }

}
