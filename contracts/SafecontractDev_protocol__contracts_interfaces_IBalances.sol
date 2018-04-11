pragma solidity ^0.4.15;

contract IBalances {
    function queryBalance(address _account) public constant returns (uint);
}