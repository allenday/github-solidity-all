pragma solidity ^0.4.2;

contract SimpleConsent {
    string id;
    address customer;
    address data_requester;
    address data_owner;

    enum State {Created, Requested, Given, Revoked, Rejected}
    State public state = State.Created;

    modifier atState(State _state) {
        if (state != _state) throw;
        _;
    }

    event ConsentRequested (string id, address data_requester, address customer, address data_owner);
    event ConsentGiven (string id, address data_requester, address customer, address data_owner);
    event ConsentRejected (string id, address data_requester, address customer, address data_owner);

    function SimpleConsent(string _id, address _customer, address _data_owner) {
        data_requester = msg.sender;
        id = _id;
        customer = _customer;
        data_owner = _data_owner;
        state = State.Created;
    }

    function requestConsent() atState(State.Created) {
        // TODO: check that msg sender is data_requester
        state = State.Requested;
        ConsentRequested(id, data_requester, customer, data_owner);
    }

    function giveConsent() atState(State.Requested) {
        // TODO: check that msg.sender is customer
        state = State.Given;
        ConsentGiven(id, data_requester, customer, data_owner);
    }

    function rejectConsent() atState(State.Requested) {
        // TODO: check that msg.sender is customer
        state = State.Rejected;
        ConsentRejected(id, data_requester, customer, data_owner);
    }
}
