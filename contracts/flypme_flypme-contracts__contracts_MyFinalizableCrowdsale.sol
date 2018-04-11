pragma solidity ^0.4.15;

import 'zeppelin-solidity/contracts/math/SafeMath.sol';
import 'zeppelin-solidity/contracts/ownership/Ownable.sol';
import 'zeppelin-solidity/contracts/crowdsale/FinalizableCrowdsale.sol';

/**
 * @title FinalizableCrowdsale
 * @dev Extension of Crowsdale where an owner can do extra work
 * after finishing. By default, it will end token minting.
 */
contract MyFinalizableCrowdsale is FinalizableCrowdsale {
  using SafeMath for uint256;
  // address where funds are collected
  address public tokenWallet;

  event FinalTokens(uint256 _generated);

  function MyFinalizableCrowdsale(address _tokenWallet) {
    tokenWallet = _tokenWallet;
  }

  function generateFinalTokens(uint256 ratio) internal {
    uint256 finalValue = token.totalSupply();
    finalValue = finalValue.mul(ratio).div(1000);

    token.mint(tokenWallet, finalValue);
    FinalTokens(finalValue);
  }

}
