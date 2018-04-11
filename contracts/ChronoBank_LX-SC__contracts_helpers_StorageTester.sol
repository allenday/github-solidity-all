/**
 * Copyright 2017–2018, LaborX PTY
 * Licensed under the AGPL Version 3 license.
 */

pragma solidity ^0.4.18;

import '../adapters/StorageAdapter.sol';

contract StorageTester is StorageAdapter {

    StorageInterface.UInt uintVar;
    StorageInterface.Int intVar;
    StorageInterface.Address addressVar;
    StorageInterface.Bool boolVar;
    StorageInterface.Bytes32 bytes32Var;
    StorageInterface.Mapping mappingVar;
    StorageInterface.AddressUIntMapping addressUIntMappingVar;
    StorageInterface.Set setVar;
    StorageInterface.AddressesSet addressesSetVar;

    function StorageTester(Storage _store, bytes32 _crate) StorageAdapter(_store, _crate) public {
        reinit();
    }

    function reinit() public {
        uintVar.init('uintVar');
        intVar.init('intVar');
        addressVar.init('addressVar');
        boolVar.init('boolVar');
        bytes32Var.init('bytes32Var');
        mappingVar.init('mappingVar');
        addressUIntMappingVar.init('addressUIntMappingVar');
        setVar.init('setVar');
        addressesSetVar.init('addressesSetVar');
    }

    function setUInt(uint _value) external {
        store.set(uintVar, _value);
    }

    function getUInt() public view returns (uint) {
        return store.get(uintVar);
    }

    function setInt(int _value) external {
        store.set(intVar, _value);
    }

    function getInt() public view returns (int) {
        return store.get(intVar);
    }

    function setAddress(address _value) external {
        store.set(addressVar, _value);
    }

    function getAddress() public view returns (address) {
        return store.get(addressVar);
    }

    function setBool(bool _value) external {
        store.set(boolVar, _value);
    }

    function getBool() public view returns (bool) {
        return store.get(boolVar);
    }

    function setBytes32(bytes32 _value) external {
        store.set(bytes32Var, _value);
    }

    function getBytes32() public view returns (bytes32) {
        return store.get(bytes32Var);
    }

    function setMapping(bytes32 _key, bytes32 _value) external {
        store.set(mappingVar, _key, _value);
    }

    function getMapping(bytes32 _key) external view returns (bytes32) {
        return store.get(mappingVar, _key);
    }

    function setAddressUIntMapping(address _key, uint _value) external {
        store.set(addressUIntMappingVar, _key, _value);
    }

    function getAddressUIntMapping(address _key) external view returns (uint) {
        return store.get(addressUIntMappingVar, _key);
    }

    function addSet(bytes32 _value) external {
        store.add(setVar, _value);
    }

    function removeSet(bytes32 _value) external {
        store.remove(setVar, _value);
    }

    function includesSet(bytes32 _value) external view returns (bool) {
        return store.includes(setVar, _value);
    }

    function countSet() public view returns (uint) {
        return store.count(setVar);
    }

    function getSet() public view returns (bytes32[]) {
        return store.get(setVar);
    }

    function addAddressesSet(address _value) external {
        store.add(addressesSetVar, _value);
    }

    function removeAddressesSet(address _value) external {
        store.remove(addressesSetVar, _value);
    }

    function includesAddressesSet(address _value) external view returns (bool) {
        return store.includes(addressesSetVar, _value);
    }

    function countAddressesSet() public view returns (uint) {
        return store.count(addressesSetVar);
    }

    function getAddressesSet() public view returns (address[]) {
        return store.get(addressesSetVar);
    }
}
