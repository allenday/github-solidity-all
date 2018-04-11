pragma solidity ^0.4.13;

contract TokenTransferGuard {
    function onTokenTransfer(address _from, address _to, uint _amount) public returns (bool);
}