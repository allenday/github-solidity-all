pragma solidity ^0.4.15;

import "zeppelin-solidity/contracts/token/StandardToken.sol";
import "zeppelin-solidity/contracts/token/MintableToken.sol";


contract USDToken is StandardToken, MintableToken {
    string public name = "USD";
    string public symbol = "USD";
    uint256 public decimals = 18;
}
