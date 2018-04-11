pragma solidity ^0.4.0;

contract MessageRegistry {
    mapping(uint => string) private messages;
    mapping(uint => uint) private timestamps;
    mapping(uint => address) private senders;
    mapping(uint => address) private receivers;
    bytes32  hashCurrent;
    uint currentTimestamp;

    function save(string message, address receiver, uint identifier) returns (bytes32) {
        bytes memory emptyCheck = bytes(messages[identifier]);
        if (emptyCheck.length == 0) {
            currentTimestamp = block.timestamp;
            messages[identifier] = message;
            timestamps[identifier] = currentTimestamp;
            senders[identifier] = msg.sender;
            receivers[identifier] = receiver;
        }
        else {
            return;
        }
    }
    function getMessage(uint identifier) constant returns (string, uint, address, address) {
        return (messages[identifier],timestamps[identifier],senders[identifier],receivers[identifier]);
    } 
    function isDeployed() constant returns (bool) {
        return true;
    }
}