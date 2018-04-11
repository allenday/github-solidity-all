pragma solidity ^0.4.0;

contract LotteryClaveChain
{
    struct Request
    {
        address requester;
        bytes4 callback;
        bool isDone;
    }

    address clave;
    uint64 public currentId;
    mapping (uint64 => Request) public requests;
    uint256 constant REQUEST_ETH = 0x10000000000000;

    function LotteryClaveChain(address _clave) public {
        clave = _clave;
    }

    function Register(bytes4 callback) payable public
    {
        if(msg.value < REQUEST_ETH)
        {
            throw;
        }
        uint64 id = currentId;
        currentId++;
        requests[id].requester = msg.sender;
        requests[id].callback = callback;
        requests[id].isDone = false;
        clave.transfer(REQUEST_ETH);
    }

    function SendResult(uint64 id, uint64 number) public
    {
        if(requests[id].isDone) {
            throw;
        }
        if(msg.sender != clave){
            throw;
        }

        address requester = requests[id].requester;
        bytes4 callback = requests[id].callback;
        requester.call(callback, number);
        requests[id].isDone = true;
    }
}
