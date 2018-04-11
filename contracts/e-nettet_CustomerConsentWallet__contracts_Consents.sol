pragma solidity ^0.4.6;

contract Consents {
    address owner;

    // mappings between id/customer addresses and consent array indexes, public accessible on key
    mapping (uint => uint) public id_mapping;
    mapping (address => uint[]) public customer_mapping;

    // array of all consents, public accessible on index
    Consent[] public consents;

    enum State {Requested, Given, Revoked, Rejected}

    struct Consent {
        uint id; // id is assumed to be a UUID
        address data_requester;
        address customer;
        address data_owner;
        State state;
    }

    event ConsentRequested (address customer, address data_owner, address data_requester, uint id);
    event ConsentUpdated (bool updated, address customer, address data_owner, address data_requester, State state, uint id);
    event DataRequested (address customer, address data_owner, address data_requester, uint id);
    event DataProvided (address customer, address data_owner, address data_requester, uint id, bytes payload);

    // used for debugging
    event PrintAddress(address x);
    event Printbytes(bytes x);

    function Consents() payable {
        owner = msg.sender;
    }

    function requestConsent(address customer, address data_owner, uint id) {
        var c = Consent(id, msg.sender, customer, data_owner, State.Requested);
        uint length = consents.push(c);
        uint index = length - 1;
        id_mapping[id] = index;
        customer_mapping[customer].push(index);
        ConsentRequested(customer, data_owner, msg.sender, id);
    }

    // assumes that it is called by customer
    function updateConsent(address data_requester, address data_owner, uint id, State state) returns (bool) {
      var updated = changeConsent(msg.sender, data_owner, data_requester, id, state);
      ConsentUpdated(updated, msg.sender, data_owner, data_requester, state, id);
      return updated;
    }

    function getConsent(uint index) constant returns (address, address, address, State, uint) {
        return (consents[index].data_requester, consents[index].customer, consents[index].data_owner, consents[index].state, consents[index].id);
    }

    function customerConsents(address customer) constant returns (uint) {
        return customer_mapping[customer].length;
    }

    function changeConsent(address customer, address data_owner, address data_requester, uint id, State newState) private returns (bool) {
        var index = id_mapping[id];
        Consent consent = consents[index];

        if (consent.customer == customer &&
            consent.data_owner == data_owner &&
            consent.data_requester == data_requester &&
            consent.state != newState) {
                consent.state = newState;
                return true;
            }

        return false;
    }

    function requestData(address customer, address data_owner, uint id) {

        var index = id_mapping[id];
        Consent consent = consents[index];

        if (consent.state == State.Given &&
            consent.customer == customer &&
            consent.data_requester == msg.sender &&
            consent.data_owner == data_owner) {
                DataRequested(customer, data_owner, msg.sender, id);
        } else {
            throw;
        }
    }

    function provideData(address customer, address data_requester, uint id, bytes payload) {

        var index = id_mapping[id];
        Consent consent = consents[index];

        if (consent.state == State.Given &&
            consent.customer == customer &&
            consent.data_requester == data_requester &&
            consent.data_owner == msg.sender) {
                DataProvided(customer,  msg.sender, data_requester, id, payload);
        } else {
            throw;
        }
    }

    function kill() {
        if (msg.sender == owner) {
            selfdestruct(owner);
        }
    }
}
