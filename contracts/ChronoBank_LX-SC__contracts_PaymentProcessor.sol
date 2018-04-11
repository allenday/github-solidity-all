/**
 * Copyright 2017–2018, LaborX PTY
 * Licensed under the AGPL Version 3 license.
 */

pragma solidity ^0.4.18;

import './adapters/Roles2LibraryAdapter.sol';


contract PaymentGatewayInterface {
    function transferWithFee(address _from, address _to, uint _value, uint _feeFromValue, uint _additionalFee, address _contract) public returns (uint);
    function transferAll(address _from, address _to, uint _value, address _change, uint _feeFromValue, uint _additionalFee, address _contract) public returns (uint);
}


contract PaymentProcessor is Roles2LibraryAdapter {

    uint constant PAYMENT_PROCESSOR_SCOPE = 16000;
    uint constant PAYMENT_PROCESSOR_OPERATION_IS_NOT_APPROVED = PAYMENT_PROCESSOR_SCOPE + 1;


    PaymentGatewayInterface public paymentGateway;
    bool public serviceMode = false;
    mapping(bytes32 => bool) public approved;

    modifier onlyApproved(bytes32 _operationId) {
        if (serviceMode && !approved[_operationId]) {
            assembly {
                mstore(0, 16001) // PAYMENT_PROCESSOR_OPERATION_IS_NOT_APPROVED
                return(0, 32)
            }
        }

        _;

        if (serviceMode) {
            delete approved[_operationId];
        }
    }

    function PaymentProcessor(address _roles2Library) public Roles2LibraryAdapter(_roles2Library) {}


    // Only contract owner
    function setPaymentGateway(PaymentGatewayInterface _paymentGateway) auth external returns (bool) {
        paymentGateway = _paymentGateway;
        return true;
    }

    // Only contract owner
    function enableServiceMode() auth external returns (uint) {
        serviceMode = true;
        return OK;
    }

    // Only contract owner
    function disableServiceMode() auth external returns (uint) {
        delete serviceMode;
        return OK;
    }

    // Only contract owner
    function approve(uint _operationId) auth external returns (uint) {
        approved[bytes32(_operationId)] = true;
        return OK;
    }

    function lockPayment(
        bytes32 _operationId,
        address _from,
        uint _value,
        address _contract
    )
    auth  // Only job controller
    onlyApproved(_operationId)
    external
    returns (uint) {
        return paymentGateway.transferWithFee(_from, address(_operationId), _value, 0, 0, _contract);
    }

    function releasePayment(
        bytes32 _operationId,
        address _to,
        uint _value,
        address _change,
        uint _feeFromValue,
        uint _additionalFee,
        address _contract
    )
    auth  // Only job controller
    onlyApproved(_operationId)
    external
    returns (uint) {
        return paymentGateway.transferAll(
            address(_operationId),
            _to,
            _value,
            _change,
            _feeFromValue,
            _additionalFee,
            _contract
        );
    }
}
