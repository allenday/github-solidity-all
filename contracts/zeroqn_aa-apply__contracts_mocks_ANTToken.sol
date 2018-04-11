pragma solidity ^0.4.15;

import "zeppelin-solidity/contracts/token/StandardToken.sol";
import "zeppelin-solidity/contracts/token/MintableToken.sol";


contract ANTToken is StandardToken, MintableToken {
    string public name = "ANT";
    string public symbol = "ANT";
    uint256 public decimals = 18;
}
