pragma solidity ^0.4.11;

contract cocoon {
    // Nested mapping: funds[initiator][intermediary][receiver] contains the value of ETH locked up by that triple.
    mapping (address => mapping (address => mapping (address => uint))) funds;

    // The account from where ETH is received is the initiator.
    function storeInContract(address intermediary, address receiver) payable {
        funds[msg.sender][intermediary][receiver] += msg.value;
    }

    // Get amount of ETH locked up with a triple.
    function getValue(address initiator, address intermediary, address receiver) constant returns (uint) {
        return funds[initiator][intermediary][receiver];
    }

    // Common function used to check is sufficient balance is present in a trio and send it to the target if that is the case.
    function sendToTarget(address initiator, address intermediary, address receiver, address target, uint amount) internal {
        if (funds[initiator][intermediary][receiver] >= amount) {
            funds[initiator][intermediary][receiver] -= amount;
            target.transfer(amount);
        }
        else {
            throw;
        }
    }

    // Send ETH to the receiver from the initiator.
    function sendToReceiver(address intermediary, address receiver, uint amount) {
        sendToTarget(msg.sender, intermediary, receiver, receiver, amount);
    }

    // Send ETH to the receiver from the intermediary.
    function moveToReceiver(address initiator, address receiver, uint amount) {
        sendToTarget(initiator, msg.sender, receiver, receiver, amount);
    }

    // Send ETH to the initiator from the intermediary.
    function moveToInitiator(address initiator, address receiver, uint amount) {
        sendToTarget(initiator, msg.sender, receiver, initiator, amount);
    }
}
