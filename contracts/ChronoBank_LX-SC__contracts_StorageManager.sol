/**
 * Copyright 2017–2018, LaborX PTY
 * Licensed under the AGPL Version 3 license.
 */

pragma solidity ^0.4.11;

import './adapters/MultiEventsHistoryAdapter.sol';
import './base/Owned.sol';


contract StorageManager is MultiEventsHistoryAdapter, Owned {
    mapping(address => mapping(bytes32 => bool)) internal approvedContracts;
    event AccessGiven(address indexed self, address actor, bytes32 role);
    event AccessBlocked(address indexed self, address actor, bytes32 role);

    function setupEventsHistory(address _eventsHistory) public onlyContractOwner() returns(bool) {
        if (getEventsHistory() != 0x0) {
            return false;
        }
        _setEventsHistory(_eventsHistory);
        return true;
    }

    function giveAccess(address _actor, bytes32 _role) public onlyContractOwner() returns(bool) {
        approvedContracts[_actor][_role] = true;
        _emitAccessGiven(_actor, _role);
        return true;
    }

    function blockAccess(address _actor, bytes32 _role) public onlyContractOwner() returns(bool) {
        approvedContracts[_actor][_role] = false;
        _emitAccessBlocked(_actor, _role);
        return true;
    }

    function isAllowed(address _actor, bytes32 _role) public view returns(bool) {
        return approvedContracts[_actor][_role];
    }

    function _emitAccessGiven(address _user, bytes32 _role) internal {
        StorageManager(getEventsHistory()).emitAccessGiven(_user, _role);
    }

    function _emitAccessBlocked(address _user, bytes32 _role) internal {
        StorageManager(getEventsHistory()).emitAccessBlocked(_user, _role);
    }

    function emitAccessGiven(address _user, bytes32 _role) public {
        AccessGiven(_self(), _user, _role);
    }

    function emitAccessBlocked(address _user, bytes32 _role) public {
        AccessBlocked(_self(), _user, _role);
    }
}
