pragma solidity ^0.4.8;

contract ICreditBOND{
    function getBondMultiplier(uint _creditAmount, uint _locktime) constant returns (uint bondMultiplier) {}
    function getNewCoinsIssued(uint _lockedBalance, uint _blockDifference, uint _percentReward) constant returns(uint newCoinsIssued){}
}