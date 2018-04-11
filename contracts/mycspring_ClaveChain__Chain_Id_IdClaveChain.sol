pragma solidity ^0.4.0;

contract IdClaveChain
{
    struct Request
    {
        address requester;
        bytes4 callback;
        bool isDone;
        bytes32 user;
        // eight part of RSA encrypted password
        bytes32 encPassword_0;
        bytes32 encPassword_1;
        bytes32 encPassword_2;
        bytes32 encPassword_3;
        bytes32 encPassword_4;
        bytes32 encPassword_5;
        bytes32 encPassword_6;
        bytes32 encPassword_7;
    }

    address clave;
    uint64 public currentId;
    mapping (uint64 => Request) public requests;
    uint256 constant REQUEST_ETH = 0x10000000000000;

    function IdClaveChain(address _clave) public {
        clave = _clave;
    }

    function Register(bytes4 callback, bytes32 user, bytes32[8] encPassword) payable public
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
        requests[id].user = user;
        requests[id].encPassword_0 = encPassword[0];
        requests[id].encPassword_1 = encPassword[1];
        requests[id].encPassword_2 = encPassword[2];
        requests[id].encPassword_3 = encPassword[3];
        requests[id].encPassword_4 = encPassword[4];
        requests[id].encPassword_5 = encPassword[5];
        requests[id].encPassword_6 = encPassword[6];
        requests[id].encPassword_7 = encPassword[7];
        clave.transfer(REQUEST_ETH);
    }

    function SendResult(uint64 id, bytes32 user, bytes32 hashSaltPassword) public
    {
        if(requests[id].isDone) {
            throw;
        }
        if(msg.sender != clave){
            throw;
        }

        address requester = requests[id].requester;
        bytes4 callback = requests[id].callback;
        requester.call(callback, user, hashSaltPassword);
        requests[id].isDone = true;
    }
}
