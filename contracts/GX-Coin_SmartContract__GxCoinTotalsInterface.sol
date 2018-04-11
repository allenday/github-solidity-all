pragma solidity ^0.4.2;

contract GxCoinTotalsInterface {
    uint32 public constant maxCoinLimit = 75000000;
    uint32 public coinLimit;
    uint32 public totalCoins;

    function setCoinLimit(uint32 limit) public;
    function adjustTotalCoins(int32 coins) public returns (bool);
    function setTotalCoins(uint32 coins) public;
}
