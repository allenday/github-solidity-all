pragma solidity ^0.4.13;

import "./token/DonorToken.sol";
import "./crowdsale/DonorCrowdsale.sol";

/**
 * @title MDToken
 * @dev ERC token meant to be used in a crowdsale contract.
 * Example; customize before deploying!
 */
contract MDToken is DonorToken {

  string public constant name = "MyDonorToken";
  string public constant symbol = "MDT";
  uint8 public constant decimals = 3;

}

/**
 * @title MDTCrowdsale
 * @dev Crowdsale contract to sell ERC tokens.
 * Example; customize before deploying!
 */
contract MDTCrowdsale is DonorCrowdsale {

  uint256 public constant TOKEN_RATE = 1 szabo; // ether cost per token, aka minimum payment
  address public constant INITIAL_WALLET = 0x2F6dA3986a36f8dBd559b94CF9D6857779b429E2; // that's us!

  function MDTCrowdsale(address _tokenAddr)
    DonorCrowdsale(now, UINT256_MAX, TOKEN_RATE, INITIAL_WALLET, CAP_DEFAULT)
  {
    // instead of Crowdsale creating token, we create it beforehand to decouple & split gas costs
  	token = MDToken(_tokenAddr);
    // remember to also token.transferOwnership to this contract after deploying
  }

  function createTokenContract() internal returns (MintableToken) {
    return token; // don't actually create new token since we're assigning in constructor
  }

}