/**
 * Copyright 2017–2018, LaborX PTY
 * Licensed under the AGPL Version 3 license.
 */

pragma solidity ^0.4.18;


import './User.sol';
import './adapters/Roles2LibraryAdapter.sol';


contract Recovery is Roles2LibraryAdapter {

    uint constant RECOVERY_SCOPE = 19000;

    event UserRecovered(address prevUser, address newUser, User userContract);

    function Recovery(address _roles2Library) Roles2LibraryAdapter(_roles2Library) public {}

    function recoverUser(User _userContract, address _newAddress) auth public returns (uint) {
        address prev = _userContract.contractOwner();
        if (OK != _userContract.recoverUser(_newAddress)) {
            revert();
        }

        UserRecovered(prev, _newAddress, _userContract);
        return OK;
    }

}
