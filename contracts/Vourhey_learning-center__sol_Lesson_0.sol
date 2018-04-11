pragma solidity ^0.4.4;

contract Lesson_0 {
    mapping(address => bool) public isSended;
    
    function ping() {
        if (isSended[msg.sender]) throw;
        if (msg.sender.send(5 ether)) throw;
        isSended[msg.sender] = true;
    }
}
