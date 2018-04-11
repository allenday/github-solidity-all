pragma solidity ^0.4.13;

import './MintableToken.sol';


contract MingoToken is MintableToken {
    string public constant name = "MingoToken";
    string public constant symbol = "MGT";
    uint8 public constant decimals = 0;
}
