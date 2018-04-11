pragma solidity ^0.4.0;

contract KycClaveChain
{
    struct Request
    {
        address requester;
        bytes4 callback;
        bytes18 index;
        bool isDone;
    }

    address clave;
    uint64 public currentId;
    mapping (uint64 => Request) public requests;
    uint256 constant REQUEST_ETH = 0x10000000000000;

    function KycClaveChain(address _clave) public
    {
        clave = _clave;
        currentId = 0;
    }

    function Register(address requester, bytes4 callback, bytes18 index) payable public returns(uint64)
    {
        if(msg.value < REQUEST_ETH) {
            throw;
        }

        uint64 id = currentId;
        currentId++;
        requests[id].requester = requester;
        requests[id].callback = callback;
        requests[id].index = index;
        requests[id].isDone = false;
        clave.transfer(REQUEST_ETH);
        return id;
    }

    function SendResult(uint64 id, bytes18 index, bytes32 name, bytes11 phone) public
    {
        if(requests[id].isDone) {
            throw;
        }

        if(msg.sender != clave || index != requests[id].index){
            throw;
        }

        address requester = requests[id].requester;
        bytes4 callback = requests[id].callback;
        requester.call(callback, id, index, name, phone);
        requests[id].isDone = true;
    }
}
