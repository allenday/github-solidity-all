pragma solidity ^0.4.11;


// THIS CONTRACT CONTAINS BUGS - DO NOT USE
contract TxOriginContract {
    address owner;

    function TxOriginContract() {
        owner = msg.sender;
    }

    function transferTo(address dest, uint amount) {
        require(tx.origin == owner);
        dest.transfer(amount);
    }

    function anotherTransferTo(address dest, uint amount) {
        require(owner == tx.origin);
        dest.transfer(amount);
    }

    function yetAnotherTransferTo(address dest, uint amount) {
        require(owner ==
            tx.origin);
        dest.transfer(amount);
    }

    // also detect tx.origin comparison when done through a variable affectation
    function transferToThroughVariable(address dest, uint amount) {
        var a = tx.origin;
        require(a == owner);
        dest.transfer(amount);
    }

    // comparing a variable linked to tx.origin against anything but msg.sender should not matter
    function transferToThroughVariable(address dest, uint amount) {
        var a = tx.origin;
        require(a == owner);
        dest.transfer(amount);
    }

}