/**
 * Copyright 2017–2018, LaborX PTY
 * Licensed under the AGPL Version 3 license.
 */

pragma solidity ^0.4.18;


import './adapters/MultiEventsHistoryAdapter.sol';
import './adapters/Roles2LibraryAdapter.sol';
import './adapters/StorageAdapter.sol';


contract ERC20Library is StorageAdapter, MultiEventsHistoryAdapter, Roles2LibraryAdapter {

    event ContractAdded(address indexed self, address indexed contractAddress);
    event ContractRemoved(address indexed self, address indexed contractAddress);

    uint constant ERC20_LIBRARY_SCOPE = 12000;
    uint constant ERC20_LIBRARY_CONTRACT_EXISTS = ERC20_LIBRARY_SCOPE + 1;
    uint constant ERC20_LIBRARY_CONTRACT_DOES_NOT_EXIST = ERC20_LIBRARY_SCOPE + 2;

    StorageInterface.AddressesSet contracts;

    function ERC20Library(
        Storage _store,
        bytes32 _crate,
        address _roles2Library
    )
    StorageAdapter(_store, _crate)
    Roles2LibraryAdapter(_roles2Library)
    public
    {
        contracts.init('contracts');
    }

    function setupEventsHistory(address _eventsHistory) auth external returns (uint) {
        require(_eventsHistory != 0x0);

        _setEventsHistory(_eventsHistory);
        return OK;
    }

    function count() public view returns (uint) {
        return store.count(contracts);
    }

    function includes(address _contract) public view returns (bool) {
        return store.includes(contracts, _contract);
    }

    function getContracts() public view returns (address[]) {
        return store.get(contracts);
    }

    function getContract(uint _index) public view returns (address) {
        return store.get(contracts, _index);
    }

    function addContract(address _address) auth external returns (uint) {
        if (includes(_address)) {
            return _emitErrorCode(ERC20_LIBRARY_CONTRACT_EXISTS);
        }
        store.add(contracts, _address);
        _emitContractAdded(_address);
        return OK;
    }

    function removeContract(address _address) auth external returns (uint) {
        if (!includes(_address)) {
            return _emitErrorCode(ERC20_LIBRARY_CONTRACT_DOES_NOT_EXIST);
        }
        store.remove(contracts, _address);
        _emitContractRemoved(_address);
        return OK;
    }

    function emitContractAdded(address _address) public {
        ContractAdded(_self(), _address);
    }

    function emitContractRemoved(address _address) public {
        ContractRemoved(_self(), _address);
    }

    function _emitContractAdded(address _address) internal {
        ERC20Library(getEventsHistory()).emitContractAdded(_address);
    }

    function _emitContractRemoved(address _address) internal {
        ERC20Library(getEventsHistory()).emitContractRemoved(_address);
    }
}
