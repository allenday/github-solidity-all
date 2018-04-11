pragma solidity 0.4.7;
contract SelfDestruct {
    address owner;

    function SelfDestruct() {
        owner = msg.sender;
    }

    function give() payable {
        
    }
    function endContract() {
        if (owner != msg.sender) {
            throw;
        }
        selfdestruct(owner);
    }
}