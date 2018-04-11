pragma solidity ^0.4.2;

contract SciFi {
    mapping(bytes32 => uint) public bids;
    bytes32[1000000] public movies;
    uint public movie_num;

    function vote(bytes32 name) payable {
        if (msg.value == 0) {
            return;
        }

        uint val = bids[name];
        if (val == 0) {
            movies[movie_num++] = name;
        }

        bids[name] += msg.value;
    } 
}