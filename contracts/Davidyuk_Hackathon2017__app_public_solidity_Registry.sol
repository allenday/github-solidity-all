pragma solidity ^0.4.0;

contract Registry {
    address public owner;
    string public name;

    address[] public performerStorage;
    uint32[] public operationStorage;

    mapping (address => Performer) public performers;
    mapping (uint32 => OperationType) public operationTypes;

    uint32 operationTypeCounter;

    struct Performer {
        string name;
        uint8 rating;
        string description;
    }

    struct OperationType {
        string name;
        string description;
    }

    function Registry(string _name) {
        owner = msg.sender;
        name = _name;

        operationTypes[1] = OperationType("owner change", "");
        operationTypeCounter = 2;
    }

    function addPerformer(address performer, string name, uint8 rating, string description) isOwner {
        if (rating == 0) throw;

        performerStorage.push(performer);
        performers[performer] = Performer(name, rating, description);
    }

    function addOperationType(string name, string description) isOwner {
        if (bytes(description).length == 0) throw;

        uint32 id = operationTypeCounter++;
        operationStorage.push(id);
        operationTypes[id] = OperationType(name, description);
    }

    function removePerformer(address performer) isOwner {
        for (uint i = 0; i < performerStorage.length; i++)
            if (performerStorage[i] == performer) delete performerStorage[i];
        delete performers[performer];
    }

    function removeOperationType(uint32 id) isOwner {
        for (uint i = 0; i < operationStorage.length; i++)
            if (operationStorage[i] == id) delete operationStorage[i];
        delete operationTypes[id];
    }

    function verifyOperation(address performer, uint32 operation) constant returns(bool) {
        return (performers[performer].rating != 0) && (bytes(operationTypes[operation].description).length != 0);
    }

    function touch() isOwner constant returns(bool) {
        return true;
    }

    modifier isOwner() {
        if (msg.sender != owner) throw;
        _;
    }
}
