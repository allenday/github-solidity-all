/**
 * Copyright 2017–2018, LaborX PTY
 * Licensed under the AGPL Version 3 license.
 */

pragma solidity ^0.4.18;


import './User.sol';
import './UserProxy.sol';
import './base/Owned.sol';


contract User is Owned {

    uint constant OK = 1;

    UserProxy userProxy;
    address recoveryContract;

    modifier onlyRecoveryContract() {
        if (recoveryContract == msg.sender) {
            _;
        }
    }

    function User(address _owner, address _recoveryContract) public {
        userProxy = new UserProxy();
        recoveryContract = _recoveryContract;
        contractOwner = _owner;
    }

    function setUserProxy(UserProxy _userProxy) onlyContractOwner public returns (uint) {
        userProxy = _userProxy;
        return OK;
    }

    function getUserProxy() public view returns(address) {
        return userProxy;
    }

    function setRecoveryContract(address _recoveryContract) onlyContractOwner public returns (uint) {
        recoveryContract = _recoveryContract;
        return OK;
    }

    function forward(
        address _destination,
        bytes _data,
        uint _value,
        bool _throwOnFailedCall
    )
    onlyContractOwner
    public
    returns (bytes32) 
    {
        return userProxy.forward(_destination, _data, _value, _throwOnFailedCall);
    }

    function recoverUser(address newAddress) onlyRecoveryContract public returns (uint) {
        contractOwner = newAddress;
        return OK;
    }

}
