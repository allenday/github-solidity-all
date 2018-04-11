pragma solidity ^0.4.8;

/// A deliberately exploitable contract created by the B9Labs team to demonstrate a contract which suffers from
/// a re-entrant exploit - including the use of a verbose mechanism for sending Ether that allows for a greater amount
/// of gas to be included in the transaction; when compared with a straight call to <code>msg.sender.send(balances[msg.sender])</code>
contract HoneyPot {
    mapping (address => uint) public balances;

    function HoneyPot() payable {
        put();
    }

    function put() payable {
        balances[msg.sender] = msg.value;
    }

    function get() {
        if (!msg.sender.call.value(balances[msg.sender])()) {
            throw;
        }
        balances[msg.sender] = 0;
    }

    function() {
        throw;
    }
}