pragma solidity ^0.4.0;

contract TicketMultiTear {
    address public owner;
    string ticketName;
    
    struct Tear {
        string name;
    }
    
    struct TicketHolder {
        mapping(address => Tear) public ticketTypes;
    }
    
    /* this function is executed at initialization and sets the owner of the contract */
    function mortal() { owner = msg.sender; }
    
    Tear[] public tears;
    
    mapping(address => TicketHolder) public ticketHolders;
    
    /* Constructor */
    function TicketMultiTear(string _ticketName, string[] _tearName, uint[] _startingTickets) is mortal {
        owner = msg.sender;
        ticketName = _ticketName;
        for (uint i = 0; i < _tearName.length; i++) {
            tears.push(Tear({
                name: _tearName[i],
            }));
            ticketHolders[owner].push(ticketHolder({
                ticketTypes[i] = _startingTickets[i]
            }));
        }
    }
    
    /* Function to recover the funds on the contract */
    function kill() { if (msg.sender == owner) selfdestruct(owner); }
    
    function transfer(address _to, string _tear, uint _value) returns (bool _success) {
        if (ticketHolders[msg.sender].ticketTypes[_tear] < _value) {
            return false;
        }
        ticketHolders[msg.sender].ticketTypes[_tear] -= _value;
        ticketHolders[_to].ticketTypes[_tear] += _value;
        return true;
    }
    
    function getTicketCount(address _user, string _tear) constant returns (uint _ticketCount) {
        return ticketHolders[_user].ticketTypes[_tear];
    }
    
    function consumeTicket(address _user, string _tear, uint _count) returns (bool _success) {
        if (msg.sender == owner && ticketHolders[_user].ticketTypes[_tear] >= _count) {
            ticketHolders[_user].ticketTypes[_tear] -= _count;
            ticketHolders[owner].ticketTypes[_tear] += _count;
            return true;
        }
        return false;
    }
}
