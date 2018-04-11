pragma solidity ^0.4.0;

import "github.com/mycspring/ClaveChain/Chain/Id/IIdClaveChain.sol";

contract Id is IIdClaveChain
{
    bytes4 constant callback = 0x1fb4bcf8;
    address clave;
    mapping(bytes32 => bytes32) public users;

    function Id(IIdClaveChain _idClaveChain) public
    {
        creator = msg.sender;
        idClaveChain = _idClaveChain;
    }


    function RegisterUser(bytes32 user, bytes32[8] encPassword) payable public
    {
        if(msg.sender == creator) {
            idClaveChain.Register.value(msg.value)(callback, user, encPassword);
        }
    }

    function SetSaltPassword(bytes32 user, bytes32 hashSaltPassword) public
    {
        if(msg.sender == address(idClaveChain))
        {
            users[user] = hashSaltPassword;
        }
    }
}
