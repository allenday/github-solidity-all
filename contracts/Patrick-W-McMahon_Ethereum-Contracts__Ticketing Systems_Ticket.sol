pragma solidity ^0.4.0;

contract Ticket {
    address public owner;
    string ticketName;
    mapping (address => uint) tickets;
    
    /* this function is executed at initialization and sets the owner of the contract */
    function mortal() { owner = msg.sender; }
    
    /* Constructor */
    function Ticket(string _ticketName, uint _startingTickets) is mortal {
        owner = msg.sender;
        ticketName = _ticketName;
        tickets[owner] = _startingTickets;
    }
    
    /* transfer tickets to user */
    function transfer(address _to, uint _value) returns (bool _success) {
        if (tickets[msg.sender] < _value) {
            return false;
        }
        tickets[msg.sender] -= _value;
        tickets[_to] += _value;
        return true;
    }
    
    /* Function to recover the funds on the contract */
    function kill() { if (msg.sender == owner) selfdestruct(owner); }
    
    /* Get the number of tickets a user has */
    function getTicketCount(address _user) constant returns (uint _ticketCount) {
        return tickets[_user];
    }
    
    function consumeTicket(address _user, uint _count) returns (bool _success) {
        if (msg.sender == owner && tickets[_user] >= _count) {
            tickets[_user] -= _count;
            tickets[owner] += _count;
            return true;
        }
        return false;
    }
}
