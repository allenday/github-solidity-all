pragma solidity ^0.4.0;

import "github.com/mycspring/ClaveChain/Chain/Kyc/IKycClaveChain.sol";

contract CustomerInfo is IKycClaveChain
{
    struct Customer
    {
        bytes32 name;
        bytes11 phone;
        bool isExist;
    }

    bytes4 callback = 0x3a4cba05;
    mapping(bytes18 => Customer) public customers;
    uint64 reqid;

    function CustomerInfo(IKycClaveChain _kycClaveChain) public
    {
        kycClaveChain = _kycClaveChain;
        creator = msg.sender;
        reqid = 0;
    }

    function GetOtherCustomerInfo(bytes18 index) payable public
    {
        reqid = kycClaveChain.Register.value(msg.value)(this, callback, index);
    }

    function SetCustomerInfo(uint64 requestId, bytes18 index, bytes32 name, bytes11 phone) public
    {
        if(requestId != reqid) {
            throw;
        }
        if(msg.sender == address(kycClaveChain))
        {
            customers[index].name = name;
            customers[index].phone = phone;
            customers[index].isExist = true;
        }
    }
}
