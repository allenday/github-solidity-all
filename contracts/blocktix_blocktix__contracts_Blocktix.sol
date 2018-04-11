// This is a simple ticket sales contract
//
// TODO: Create tokens, send fees to token holders

pragma solidity ^0.4.8;

contract Blocktix {

    // The organizer of the event
    address public organizer;
    // The name of the event
    string name;
    // All tickets
    TicketType[] public tickets;
    // Ticket bids
    TicketBid[] public bids;

    struct TicketType {
        // A plain text description of the ticket type, i.e.: VIP, Standing, Seated, etc...
        string description;
        // The price of the ticket
        uint price;
        // The amount of tickets available
        uint quota;
        // The amount of tickets sold
        uint owners;
        // map ticket to owner
        mapping (address => uint) paid;
    }

    struct TicketBid {
        // The owner of the bid
        address owner;
        // Is buy or sell bid
        bool buy;
        // Bid price
        uint price;
        // The type of ticket the buyer or seller is bidding
        uint ticketID;
    }

    event BuyTicket(uint _id, address _from, uint _amount); // so you can log the event

    function Blocktix(
        string _name,
        uint _price,
        uint _quota
    ) {
        organizer = msg.sender;
        name = _name;
        // Set defaults
        TicketType t = tickets[tickets.length];
        t.description = _name;
        t.price = _price;
        t.quota = _quota;
        t.owners = 0;
    }

    function buyTicket(
        uint _ticketID
    ) payable {
        TicketType t = tickets[_ticketID];
        if (t.owners >= t.quota || t.price > msg.value) {
            throw; // throw ensures funds will be returned
        }

        if (t.paid[msg.sender] > 0) {
            throw; // only 1 ticket per address
        }
        t.paid[msg.sender] = msg.value;
        t.owners++;
        BuyTicket(_ticketID, msg.sender, msg.value);
    }

    modifier organizerOnly() {
        if (msg.sender != organizer) { throw; }
        _;
    }

    function changeTicketType(
        uint _ticketID,
        string _description,
        uint _quota
    ) organizerOnly() public {
        TicketType t = tickets[_ticketID];
        if (t.owners > _quota) { return; } // can't make quota lower than amount already sold
        t.description = _description;
        t.quota = _quota;
    }


    function refundTicket(
        address owner,
        uint _ticketID
    ) organizerOnly() public {

        address contractAddress = this;
        if (_ticketID < 0) { // Refund all tickets purchased by owner
            for (uint i=0; i<tickets.length; i++) {
                if (tickets[i].owners == 0 || contractAddress.balance < tickets[i].paid[owner] || tickets[i].paid[owner] <= 0) {
                    continue;
                }
                //TODO: Events
                if(!contractAddress.send(tickets[i].paid[owner] - (tickets[i].paid[owner] / 20))) // 5% refund fee
                    throw;
                tickets[i].paid[owner] = 0;
                tickets[i].owners--;
            }
        } else {
            TicketType t = tickets[_ticketID];
            if (t.owners == 0 || contractAddress.balance < t.paid[owner] || t.paid[owner] <= 0) {
                return;
            }
            //TODO: Events
            if(!owner.send(t.paid[owner] - (t.paid[owner] / 20))) // 5% refund fee
                throw;
            t.paid[owner] = 0;
            t.owners--;
        }

        return;
    }

    function transferTicket(
        uint _ticketID,
        address newOwner
    ) public {
        // TODO: Enforce minimum % paid to contract
        TicketType t = tickets[_ticketID];
        if (t.paid[msg.sender] > 0) {
            uint value = t.paid[msg.sender];
            t.paid[msg.sender] = 0;
            t.paid[newOwner] = value;
        }
    }

    function bidTicket(
        uint _ticketID
    ) payable {
        TicketType t = tickets[_ticketID];

        // Make sure the buyer doesn't have a ticket
        if (t.paid[msg.sender] > 0) {
            throw;
        }

        // First check bids, buy from seller if there is one
        for (uint i=0; i<bids.length; i++) {
            TicketBid bid = bids[i];
            if (bid.buy == false && bid.ticketID == _ticketID && bid.price == msg.value) {
                // We can buy it from this guy...
                uint ticketValue = t.paid[msg.sender];
                uint saleValue = bid.price;
                t.paid[bid.owner] = 0;
                delete bids[i];
                t.paid[msg.sender] = ticketValue;
                {
                    address contractAddress = this;
                    if (contractAddress.balance >= saleValue) {
                        if(!bid.owner.send(saleValue - (saleValue / 100))) // 1% sale fee
                            throw;
                        return;
                    }
                }
            }
        }

        // Now create the bid...
        bid = bids[bids.length];
        bid.buy = true;
        bid.price = msg.value;
        bid.owner = msg.sender;
        bid.ticketID = _ticketID;
    }

    function sellTicket(
        uint _ticketID
    ) payable {
        TicketType t = tickets[_ticketID];

        // Make sure the seller has a ticket
        if (t.paid[msg.sender] <= 0) {
            throw;
        }

        // First check bids, sell to bidder if there is one
        for (uint i=0; i<bids.length; i++) {
            TicketBid bid = bids[i];
            if (bid.buy == true && bid.ticketID == _ticketID && bid.price == msg.value) {
                // We can sell it to this guy...
                uint ticketValue = t.paid[msg.sender];
                uint saleValue = bid.price;
                t.paid[msg.sender] = 0;
                delete bids[i];
                t.paid[bid.owner] = ticketValue;
                {
                    address contractAddress = this;
                    if (contractAddress.balance >= saleValue) {
                        if(!msg.sender.send(saleValue - (saleValue / 100))) // 1% sale fee
                            throw;
                        return;
                    }
                }
            }
        }

        // Now create the bid...
        bid = bids[bids.length];
        bid.buy = false;
        bid.price = msg.value;
        bid.owner = msg.sender;
        bid.ticketID = _ticketID;
    }

    function cancelBid(
        uint _ticketID,
        uint price,
        bool buy
    ) public {
        for (uint i=0; i<bids.length; i++) {
            TicketBid bid = bids[i];
            if (bid.buy == buy && bid.ticketID == _ticketID && bid.price == price && bid.owner == msg.sender) {
                address contractAddress = this;
                if (contractAddress.balance >= price) {
                    delete bids[i];
                    if(!msg.sender.send(price))
                        throw;
                    return;
                }
            }
        }
    }

    function destroy() {
        if (msg.sender == organizer) {
            suicide(organizer);
        }
    }
}
