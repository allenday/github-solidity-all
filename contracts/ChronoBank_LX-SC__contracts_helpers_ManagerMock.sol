/**
 * Copyright 2017–2018, LaborX PTY
 * Licensed under the AGPL Version 3 license.
 */

pragma solidity ^0.4.18;

contract ManagerMock {

    bool denied;

    function deny() public {
        denied = true;
    }

    function isAllowed(address, bytes32) public returns(bool) {
        if (denied) {
            denied = false;
            return false;
        }
        return true;
    }
}
