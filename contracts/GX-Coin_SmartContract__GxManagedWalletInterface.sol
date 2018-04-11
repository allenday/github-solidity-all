pragma solidity ^0.4.2;

contract GxManagedWalletInterface {
    function pay(address _recipient, uint _amount) returns (bool);
}