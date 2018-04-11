pragma solidity ^0.4.2;

contract Transfer {


    // The keyword "public" makes those variables
    // readable from outside.
    address public recipient;
    mapping (address => uint) public balances;

    // Events allow light clients to react on
    // changes efficiently.
    event Sent(address from, address to, uint amount );


    function send(address receiver, uint amount) {
        if (balances[msg.sender] < amount) return;
        balances[msg.sender] -= amount;
        balances[receiver] += amount;
        return Sent(msg.sender, receiver, amount);
    }

}
