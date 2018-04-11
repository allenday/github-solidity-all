pragma solidity ^0.4.4;

contract mortal {
    address owner;

    function mortal() { owner = msg.sender; }

    function kill() { if (msg.sender == owner) selfdestruct(owner); }
}

contract EventTicket is mortal{
    event receivedEther(address sender, uint amount);
    event ticketSold(address sender, uint ref);

    mapping (uint => address) private seats;
    uint public availability;
    uint public price;
    address owner;

    function EventTicket(
    uint _tickets,
    uint _price
    ){
        availability = _tickets;
        price = _price;
        owner = msg.sender;
    }

    function () payable {
        receivedEther(msg.sender, msg.value);
    }


    function buy(uint ref) payable returns (bool success)
    {
        require(msg.value >= price);
        require(availability > 0);

        uint remaining = msg.value;
        while(remaining >= price){
            availability--;
            remaining -= price;
            seats[ref] = msg.sender;
        }

        if(remaining > 0) {
            msg.sender.transfer(remaining);
        }

        uint paid = msg.value - remaining;
        receivedEther(msg.sender, paid);
        ticketSold(msg.sender, ref);
        return true;
    }

    function hasSeat(uint ref) constant returns (bool success)
    {
        return (seats[ref] != address(0));
    }
}
