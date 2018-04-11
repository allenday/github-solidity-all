/**
 * Copyright 2017–2018, LaborX PTY
 * Licensed under the AGPL Version 3 license.
 */

pragma solidity ^0.4.18;

import './base/Owned.sol';


contract UserProxy is Owned {

    event Forwarded (
        address indexed destination,
        uint value,
        bytes data
    );
    event Received (
        address indexed sender,
        uint value
    );

    function () external payable {
        Received(msg.sender, msg.value);
    }

    function forward(
        address _destination,
        bytes _data,
        uint _value,
        bool _throwOnFailedCall
    )  
    onlyContractOwner
    public
    returns (bytes32 result) 
    {
        bool success;
        assembly {
            success := call(div(mul(gas, 63), 64), _destination, _value, add(_data, 32), mload(_data), 0, 32)
            result := mload(0)
        }
        require(success || !_throwOnFailedCall);

        Forwarded(_destination, _value, _data);
    }
}
