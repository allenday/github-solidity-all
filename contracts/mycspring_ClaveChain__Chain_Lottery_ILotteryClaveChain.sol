pragma solidity ^0.4.0;

contract ILotteryClaveChain
{
    address creator;
    ILotteryClaveChain public lotteryClaveChain;

    function Register(bytes4 callback) payable public
    {
    }

    function Update(ILotteryClaveChain _lotteryClaveChain)
    {
        if(msg.sender == creator)
        {
            lotteryClaveChain = _lotteryClaveChain;
        }
    }
}
