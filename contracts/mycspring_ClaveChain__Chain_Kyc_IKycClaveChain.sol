pragma solidity ^0.4.0;

contract IKycClaveChain
{
    IKycClaveChain public kycClaveChain;
    address creator;
    function Register(address requester, bytes4 callback, bytes18 index) payable public returns(uint64)
    {
        return 0;
    }

    function Update(IKycClaveChain _kycClaveChain)
    {
        if(msg.sender == creator)
        {
            kycClaveChain = _kycClaveChain;
        }
    }
}
