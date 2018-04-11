pragma solidity ^0.4.11;

contract owned {

    address owner;

    /*this function is executed at initialization and sets the owner of the contract */
    function owned() { owner = msg.sender; }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
}

contract mortal is owned {

    /* Function to recover the funds on the contract */
    function kill() onlyOwner() {
        selfdestruct(owner);
    }

}
