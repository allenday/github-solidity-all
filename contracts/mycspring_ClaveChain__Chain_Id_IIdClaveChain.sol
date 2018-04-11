pragma solidity ^0.4.0;

contract IIdClaveChain
{
    address creator;
    IIdClaveChain public idClaveChain;

    function Register(bytes4 callback, bytes32 user, bytes32[8] encPassword) payable public
    {
    }

    function Update(IIdClaveChain _idClaveChain)
    {
        if(msg.sender == creator)
        {
            idClaveChain = _idClaveChain;
        }
    }
}
