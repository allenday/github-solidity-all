/**
 * Copyright 2017–2018, LaborX PTY
 * Licensed under the AGPL Version 3 license.
 */

pragma solidity ^0.4.18;


import './adapters/MultiEventsHistoryAdapter.sol';
import './adapters/StorageAdapter.sol';
import './base/Owned.sol';


contract Roles2Library is StorageAdapter, MultiEventsHistoryAdapter, Owned {

    uint constant OK = 1;

    uint constant ROLES_SCOPE = 20000;
    uint constant ROLES_ALREADY_EXISTS = ROLES_SCOPE + 1;
    uint constant ROLES_INVALID_INVOCATION = ROLES_SCOPE + 2;
    uint constant ROLES_NOT_FOUND = ROLES_SCOPE + 3;

    event RoleAdded(address indexed self, address indexed user, uint8 indexed role);
    event RoleRemoved(address indexed self, address indexed user, uint8 indexed role);
    event CapabilityAdded(address indexed self, address indexed code, bytes4 sig, uint8 indexed role);
    event CapabilityRemoved(address indexed self, address indexed code, bytes4 sig, uint8 indexed role);
    event PublicCapabilityAdded(address indexed self, address indexed code, bytes4 sig);
    event PublicCapabilityRemoved(address indexed self, address indexed code, bytes4 sig);

    StorageInterface.AddressBoolMapping rootUsers;
    StorageInterface.AddressBytes32Mapping userRoles;
    StorageInterface.AddressBytes4Bytes32Mapping capabilityRoles;
    StorageInterface.AddressBytes4BoolMapping publicCapabilities;

    modifier authorized {
        if (msg.sender != contractOwner && !canCall(msg.sender, this, msg.sig)) {
            return;
        }
        _;
    }

    function Roles2Library(Storage _store, bytes32 _crate) StorageAdapter(_store, _crate) public {
        rootUsers.init('rootUsers');
        userRoles.init('userRoles');
        capabilityRoles.init('capabilityRoles');
        publicCapabilities.init('publicCapabilities');
    }

    function setupEventsHistory(address _eventsHistory) onlyContractOwner external returns (uint) {
        require(_eventsHistory != 0x0);

        _setEventsHistory(_eventsHistory);
        return OK;
    }

    function getUserRoles(address _user) public view returns (bytes32) {
        return store.get(userRoles, _user);
    }

    function getCapabilityRoles(address _code, bytes4 _sig) public view returns (bytes32) {
        return store.get(capabilityRoles, _code, _sig);
    }

    function canCall(address _user, address _code, bytes4 _sig) public view returns (bool) {
        if (isUserRoot(_user) || isCapabilityPublic(_code, _sig)) {
            return true;
        }
        return bytes32(0) != getUserRoles(_user) & getCapabilityRoles(_code, _sig);
    }

    function bitNot(bytes32 _input) public pure returns (bytes32) {
        return (_input ^ bytes32(uint(-1)));
    }

    function setRootUser(address _user, bool _enabled) onlyContractOwner external returns (uint) {
        store.set(rootUsers, _user, _enabled);
        return OK;
    }

    function addUserRole(address _user, uint8 _role) authorized external returns (uint) {
        if (hasUserRole(_user, _role)) {
            return _emitErrorCode(ROLES_ALREADY_EXISTS);
        }

        return _setUserRole(_user, _role, true);
    }

    function removeUserRole(address _user, uint8 _role) authorized external returns (uint) {
        if (!hasUserRole(_user, _role)) {
            return _emitErrorCode(ROLES_NOT_FOUND);
        }

        return _setUserRole(_user, _role, false);
    }

    function _setUserRole(address _user, uint8 _role, bool _enabled) internal returns (uint) {
        bytes32 lastRoles = getUserRoles(_user);
        bytes32 shifted = _shift(_role);
        
        if (_enabled) {
            store.set(userRoles, _user, lastRoles | shifted);
            _emitRoleAdded(_user, _role);
            return OK;
        }
    
        store.set(userRoles, _user, lastRoles & bitNot(shifted));
        _emitRoleRemoved(_user, _role);
        return OK;
    }

    function setPublicCapability(address _code, bytes4 _sig, bool _enabled) onlyContractOwner external returns (uint) {
        store.set(publicCapabilities, _code, _sig, _enabled);
        
        if (_enabled) {
            _emitPublicCapabilityAdded(_code, _sig);
        } else {
            _emitPublicCapabilityRemoved(_code, _sig);
        }
        return OK;
    }

    function addRoleCapability(uint8 _role, address _code, bytes4 _sig) onlyContractOwner public returns (uint) {
        return _setRoleCapability(_role, _code, _sig, true);
    }

    function removeRoleCapability(uint8 _role, address _code, bytes4 _sig) onlyContractOwner public returns (uint) {
        if (getCapabilityRoles(_code, _sig) == 0) {
            return _emitErrorCode(ROLES_NOT_FOUND);
        }

        return _setRoleCapability(_role, _code, _sig, false);
    }

    function _setRoleCapability(uint8 _role, address _code, bytes4 _sig, bool _enabled) public returns (uint) {
        bytes32 lastRoles = getCapabilityRoles(_code, _sig);
        bytes32 shifted = _shift(_role);

        if (_enabled) {
            store.set(capabilityRoles, _code, _sig, lastRoles | shifted);
            _emitCapabilityAdded(_code, _sig, _role);
        } else {
            store.set(capabilityRoles, _code, _sig, lastRoles & bitNot(shifted));
            _emitCapabilityRemoved(_code, _sig, _role);
        }

        return OK;
    }

    function isUserRoot(address _user) public view returns (bool) {
        return store.get(rootUsers, _user);
    }

    function isCapabilityPublic(address _code, bytes4 _sig) public view returns (bool) {
        return store.get(publicCapabilities, _code, _sig);
    }

    function hasUserRole(address _user, uint8 _role) public view returns (bool) {
        return bytes32(0) != getUserRoles(_user) & _shift(_role);
    }

    function _shift(uint8 _role) pure internal returns (bytes32) {
        return bytes32(uint(uint(2) ** uint(_role)));
    }

    function _emitRoleAdded(address _user, uint8 _role) internal {
        Roles2Library(getEventsHistory()).emitRoleAdded(_user, _role);
    }

    function _emitRoleRemoved(address _user, uint8 _role) internal {
        Roles2Library(getEventsHistory()).emitRoleRemoved(_user, _role);
    }

    function _emitCapabilityAdded(address _code, bytes4 _sig, uint8 _role) internal {
        Roles2Library(getEventsHistory()).emitCapabilityAdded(_code, _sig, _role);
    }

    function _emitCapabilityRemoved(address _code, bytes4 _sig, uint8 _role) internal {
        Roles2Library(getEventsHistory()).emitCapabilityRemoved(_code, _sig, _role);
    }

    function _emitPublicCapabilityAdded(address _code, bytes4 _sig) internal {
        Roles2Library(getEventsHistory()).emitPublicCapabilityAdded(_code, _sig);
    }

    function _emitPublicCapabilityRemoved(address _code, bytes4 _sig) internal {
        Roles2Library(getEventsHistory()).emitPublicCapabilityRemoved(_code, _sig);
    }

    function emitRoleAdded(address _user, uint8 _role) public {
        RoleAdded(_self(), _user, _role);
    }

    function emitRoleRemoved(address _user, uint8 _role) public {
        RoleRemoved(_self(), _user, _role);
    }

    function emitCapabilityAdded(address _code, bytes4 _sig, uint8 _role) public {
        CapabilityAdded(_self(), _code, _sig, _role);
    }

    function emitCapabilityRemoved(address _code, bytes4 _sig, uint8 _role) public {
        CapabilityRemoved(_self(), _code, _sig, _role);
    }

    function emitPublicCapabilityAdded(address _code, bytes4 _sig) public {
        PublicCapabilityAdded(_self(), _code, _sig);
    }

    function emitPublicCapabilityRemoved(address _code, bytes4 _sig) public {
        PublicCapabilityRemoved(_self(), _code, _sig);
    }
}
