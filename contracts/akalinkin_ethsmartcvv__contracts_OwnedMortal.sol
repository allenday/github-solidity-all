pragma solidity ^0.4.4;


contract OwnedMortal {
    address owner;

    function OwnedMortal() { owner = msg.sender; }

    modifier isContractOwner() {
        if (msg.sender != owner) throw;
        _;
    }

    function kill() isContractOwner { suicide(owner); }
}
