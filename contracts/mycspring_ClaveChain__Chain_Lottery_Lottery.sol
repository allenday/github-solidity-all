pragma solidity ^0.4.0;

import "github.com/mycspring/ClaveChain/Chain/Lottery/ILotteryClaveChain.sol";

contract Lottery is ILotteryClaveChain
{
    struct Record
    {
        address buyer;
        uint64 number;
    }

    bytes4 constant callback = 0x2371bb4b;
    uint256 constant PRICE = 0x10000;
    uint256 constant REWARD = 0x100000;
    address clave;
    mapping(uint256 => Record) public records;
    uint64 public lotteryNumber = 0;
    uint256 currentId = 0;
    bool public gotNumber = false;
    bool public isPaid = false;

    function Lottery(ILotteryClaveChain _lotteryClaveChain) public
    {
        creator = msg.sender;
        lotteryClaveChain = _lotteryClaveChain;
    }

    function Buy(uint64 number) payable public returns(uint256)
    {
        if(gotNumber)
        {
            throw;
        }
        if(msg.value != PRICE)
        {
            throw;
        }

        records[currentId].buyer = msg.sender;
        records[currentId].number = number;
        currentId++;
        creator.transfer(msg.value);
    }

    function Pay() payable public
    {
        if(!gotNumber || isPaid)
        {
            throw;
        }
        isPaid = true;

        for(uint i = 0; i < currentId; i++)
        {
            if(records[i].number == lotteryNumber)
            {
                records[i].buyer.transfer(REWARD);
            }
        }
    }

    function GetNumber() payable public
    {
        lotteryClaveChain.Register.value(msg.value)(callback);
    }

    function SetNumber(uint64 number) public
    {
        if(msg.sender == address(lotteryClaveChain))
        {
            lotteryNumber = number;
            gotNumber = true;
        }
    }
}
