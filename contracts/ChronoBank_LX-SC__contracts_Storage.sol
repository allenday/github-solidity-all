/**
 * Copyright 2017–2018, LaborX PTY
 * Licensed under the AGPL Version 3 license.
 */

pragma solidity ^0.4.11;

import './base/Owned.sol';


contract Manager {
    function isAllowed(address _actor, bytes32 _role) public view returns(bool);
}

contract Storage is Owned {
    struct Crate {
        mapping(bytes32 => uint) uints;
        mapping(bytes32 => address) addresses;
        mapping(bytes32 => bool) bools;
        mapping(bytes32 => int) ints;
        mapping(bytes32 => uint8) uint8s;
        mapping(bytes32 => bytes32) bytes32s;
        mapping(bytes32 => AddressUInt8) addressUInt8s;
    }

    struct AddressUInt8 {
        address _address;
        uint8 _uint8;
    }

    mapping(bytes32 => Crate) crates;
    Manager public manager;

    modifier onlyAllowed(bytes32 _role) {
        if (!manager.isAllowed(msg.sender, _role)) {
            revert();
        }
        _;
    }

    function setManager(Manager _manager) external onlyContractOwner() returns(bool) {
        manager = _manager;
        return true;
    }

    function setUInt(bytes32 _crate, bytes32 _key, uint _value) public onlyAllowed(_crate) {
        crates[_crate].uints[_key] = _value;
    }

    function getUInt(bytes32 _crate, bytes32 _key) public view returns(uint) {
        return crates[_crate].uints[_key];
    }

    function setAddress(bytes32 _crate, bytes32 _key, address _value) public onlyAllowed(_crate) {
        crates[_crate].addresses[_key] = _value;
    }

    function getAddress(bytes32 _crate, bytes32 _key) public view returns(address) {
        return crates[_crate].addresses[_key];
    }

    function setBool(bytes32 _crate, bytes32 _key, bool _value) public onlyAllowed(_crate) {
        crates[_crate].bools[_key] = _value;
    }

    function getBool(bytes32 _crate, bytes32 _key) public view returns(bool) {
        return crates[_crate].bools[_key];
    }

    function setInt(bytes32 _crate, bytes32 _key, int _value) public onlyAllowed(_crate) {
        crates[_crate].ints[_key] = _value;
    }

    function getInt(bytes32 _crate, bytes32 _key) public view returns(int) {
        return crates[_crate].ints[_key];
    }

    function setUInt8(bytes32 _crate, bytes32 _key, uint8 _value) public onlyAllowed(_crate) {
        crates[_crate].uint8s[_key] = _value;
    }

    function getUInt8(bytes32 _crate, bytes32 _key) public view returns(uint8) {
        return crates[_crate].uint8s[_key];
    }

    function setBytes32(bytes32 _crate, bytes32 _key, bytes32 _value) public onlyAllowed(_crate) {
        crates[_crate].bytes32s[_key] = _value;
    }

    function getBytes32(bytes32 _crate, bytes32 _key) public view returns(bytes32) {
        return crates[_crate].bytes32s[_key];
    }

    function setAddressUInt8(bytes32 _crate, bytes32 _key, address _value, uint8 _value2) public onlyAllowed(_crate) {
        crates[_crate].addressUInt8s[_key] = AddressUInt8(_value, _value2);
    }

    function getAddressUInt8(bytes32 _crate, bytes32 _key) public view returns(address, uint8) {
        return (crates[_crate].addressUInt8s[_key]._address, crates[_crate].addressUInt8s[_key]._uint8);
    }
}
