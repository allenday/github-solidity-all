/**
 * Copyright 2017–2018, LaborX PTY
 * Licensed under the AGPL Version 3 license.
 */

pragma solidity ^0.4.18;


contract UserLibraryMock {

    uint constant OK = 1;

    uint addRoleCalls = 0;
    uint setManyCalls = 0;

    function getCalls() public view returns (uint, uint){
        return (addRoleCalls, setManyCalls);
    }

    function addRole(address, bytes32) public returns (uint) {
        addRoleCalls++;
        return OK;
    }

    function setMany(address, uint, uint[], uint[]) public returns (uint) {
        setManyCalls++;
        return OK;
    }
}
