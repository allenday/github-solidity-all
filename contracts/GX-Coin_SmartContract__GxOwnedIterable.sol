pragma solidity ^0.4.2;

import './GxOwnedInterface.sol';
import './GxCallableByDeploymentAdmin.sol';
import './libraries.sol';


contract GxOwnedIterable is GxOwnedInterface, GxCallableByDeploymentAdmin {
    using IterableAddressMapping for IterableAddressMapping.iterableAddressMap;
    IterableAddressMapping.iterableAddressMap owners;

    modifier callableByOwner {
        if (isOwner(msg.sender)) {
            _;
        } else {
            throw;
        }
    }

    function isOwner(address accountAddress) public constant returns (bool) {
        return owners.contains(accountAddress);
    }

    function addOwner(address accountAddress) public callableByDeploymentAdmin {
        owners.add(accountAddress);
    }

    function removeOwner(address accountAddress) public callableByDeploymentAdmin {
        owners.remove(accountAddress);
    }

    function iterateStart() public constant returns (uint keyIndex) {
        return iterateNext(0);
    }

    function iterateValid(uint keyIndex) public constant returns (bool) {
        return owners.iterateValid(keyIndex);
    }

    function iterateNext(uint keyIndex) public constant returns (uint r_keyIndex) {
        return owners.iterateNext(keyIndex);
    }

    function iterateGet(uint keyIndex) public constant returns (address mappedAddress) {
        return owners.iterateGet(keyIndex);
    }
}