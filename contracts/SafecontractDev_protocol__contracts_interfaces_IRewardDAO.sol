pragma solidity ^0.4.15;

contract IRewardDAO {
    function onDeposit(uint _amount) public returns (bool);
    // function getEthBalance() public returns (uint);
    function claim() public;
    function deposit(address _token, uint _amount) public;
    function withdraw() public;
}