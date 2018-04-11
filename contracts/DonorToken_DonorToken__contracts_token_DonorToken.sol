pragma solidity ^0.4.13;

import "zeppelin-solidity/contracts/token/MintableToken.sol";
import "./ERC23Token.sol";
import "./ERC677Token.sol";


/**
 * @title DonorToken
 * @dev For donor-specific functionality
 */
contract DonorToken is MintableToken, ERC23Token, ERC677Token {

  uint8 public constant decimals = 18; // default, can (and usually should) be overridden

}
