/**
 * Copyright 2017–2018, LaborX PTY
 * Licensed under the AGPL Version 3 license.
 */

pragma solidity ^0.4.18;


import './adapters/MultiEventsHistoryAdapter.sol';
import './adapters/Roles2LibraryAdapter.sol';
import './adapters/StorageAdapter.sol';


contract IPFSLibrary is StorageAdapter, MultiEventsHistoryAdapter, Roles2LibraryAdapter {

    event HashSet(address indexed self, address indexed setter, bytes32 indexed key, bytes32 hash);

    StorageInterface.AddressBytes32Bytes32Mapping ipfsHashes;

    function IPFSLibrary(
        Storage _store,
        bytes32 _crate,
        address _roles2Library
    )
    StorageAdapter(_store, _crate)
    Roles2LibraryAdapter(_roles2Library)
    public
    {
        ipfsHashes.init("ipfsHashes");
    }

    function setupEventsHistory(address _eventsHistory) auth external returns (uint) {
        require(_eventsHistory != 0x0);

        _setEventsHistory(_eventsHistory);
        return OK;
    }

    function getHash(address _from, bytes32 _itemName) public view returns(bytes32) {
        return store.get(ipfsHashes, _from, _itemName);
    }

    function setHash(bytes32 _itemName, bytes32 _itemHash) public returns (uint) {
        store.set(ipfsHashes, msg.sender, _itemName, _itemHash);
        _emitHashSet(msg.sender, _itemName, _itemHash);
        return OK;
    }

    function emitHashSet(address _from, bytes32 _itemName, bytes32 _itemHash) public {
        HashSet(_self(), _from, _itemName, _itemHash);
    }

    function _emitHashSet(address _from, bytes32 _itemName, bytes32 _itemHash) internal {
        IPFSLibrary(getEventsHistory()).emitHashSet(_from, _itemName, _itemHash);
    }
}
