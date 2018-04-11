pragma solidity 0.4.11;

import './ERC20Basic.sol';

contract ERC223Basic is ERC20Basic {
    function transfer(address to, uint value, bytes data) returns (bool);
}