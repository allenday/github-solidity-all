pragma solidity ^0.4.4;

contract Property {
    string street;
    string postcode;

    function Property(string s, string p) {
        street = s;
        postcode = p;
    }
}

contract Registry {
    address public registrar;

    mapping(address => address) public ownership; // no shared ownership at the moment

    function Registry() {
        registrar = msg.sender;
    }

    function assignOwnership(address owner, Property property) {
        if (msg.sender != registrar) throw;
        ownership[property] = owner;
    }

    function isPropertyOwner(Property property) public returns (bool) {
        address owner = ownership[property];
        return msg.sender == owner;
    }
}

contract Tenancy {
    address property;
    address public owner;
    uint32 rent;
    address public tenant; // maybe this should be an array

    struct Negotiation {
        address prospectiveTenant;
        uint32 amount;
        bool rejected;
        bool accepted;
        bool withdrawn;
    }

    mapping (address => uint32) public negotiationId;
    Negotiation[] negotiations;
    uint32 numNegotiations = 1;

    // Events allow light clients to react on
    // changes efficiently.
    event Negotiate(address prospectiveTenant, address owner, uint amount);
    event RejectNegotiation(address owner, address prospectiveTenant);

    // This is the constructor whose code is
    // run only when the contract is created.
    function Tenancy(Registry registry, Property property, uint32 rent) {
        if (registry.isPropertyOwner(property)) {
            owner = msg.sender;
            property = property;
            rent = rent;
        } else {
            throw;
        }
    }

    function negotiate(uint32 amount) {
        uint32 id = negotiationId[msg.sender];
        // if already negotating then update the amount
        if (id > 0) {
            negotiations[id].amount = amount;
            negotiations[id].rejected = false;
        } else {
            negotiationId[msg.sender] = numNegotiations;
            negotiations[numNegotiations] = Negotiation(msg.sender, amount, false, false, false);
            numNegotiations++;
        }

        Negotiate(msg.sender, owner, amount);
    }

    function rejectNegotiation(address prospectiveTenant) {
        uint32 id = negotiationId[prospectiveTenant];

        if (id > 0) {
            negotiations[id].rejected = true;
            RejectNegotiation(owner, prospectiveTenant);
        } else {
            throw;
        }

    }

    Negotiation acceptedNegotiation;

    function acceptNegotiationOwner(address prospectiveTenant) {
        if (msg.sender != owner) throw;

        uint32 id = negotiationId[prospectiveTenant];
        acceptedNegotiation = negotiations[id];
    }
}
