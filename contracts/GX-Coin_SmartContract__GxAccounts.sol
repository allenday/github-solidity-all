pragma solidity ^0.4.2;

import './libraries.sol';
import './GxAccountsInterface.sol';


contract GxAccounts is GxAccountsInterface {
    using IterableAddressMapping for IterableAddressMapping.iterableAddressMap;
    IterableAddressMapping.iterableAddressMap addresses;

    //abstract
    function add(address newAddress) public;
    function remove(address removedAddress) public;

    function contains(address lookupAddress) public constant returns (bool _c){
        return addresses.contains(lookupAddress);
    }

    function iterateStart() public constant returns (uint keyIndex) {
        return iterateNext(0);
    }

    function iterateValid(uint keyIndex) public constant returns (bool) {
        return addresses.iterateValid(keyIndex);
    }

    function iterateNext(uint keyIndex) public constant returns (uint r_keyIndex) {
        return addresses.iterateNext(keyIndex);
    }

    function iterateGet(uint keyIndex) public constant returns (address mappedAddress) {
        return addresses.iterateGet(keyIndex);
    }
}