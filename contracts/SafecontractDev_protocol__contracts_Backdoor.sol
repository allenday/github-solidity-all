pragma solidity ^0.4.13;

/**
    Base contract to create a backdoor into another contract.
 */
contract Backdoor {
    address public admin;

    function Backdoor() {
        admin = msg.sender;
    }

    modifier onlyAdmin() {
        assert(msg.sender == admin);
        _;
    }

    function recoverFundsAndDestroy() 
        onlyAdmin
    {
        selfdestruct(admin);
    }

    function removeBackdoor()
        onlyAdmin
    {
        delete admin;
        assert(admin == 0x0);
    }
}