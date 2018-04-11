pragma solidity ^0.4.0;

import "./Registry.sol";

contract Auto {
    string public id;
    address public owner;
    address public registry;
    bool public hidden;

    Operation[] operations;

    struct Operation {
        uint32 id;
        address registry;
        address performer;
        string notes;
        uint date;
    }

    function Auto(address r, string _id) {
        registry = r;
        owner = msg.sender;
        id = _id;
    }

    function makeOperation(uint32 id, string notes) {
        Registry r = Registry(registry);
        if (!r.verifyOperation(msg.sender, id)) throw;

        operations.push(Operation(id, registry, msg.sender, notes, now));
    }

    function changeOwner(address newOwner) isOwner {
        owner = newOwner;
        operations.push(Operation(1, registry, newOwner, "", now));
    }

    function getOperationsLength() isPublic constant returns(uint) {
        return operations.length;
    }

    function getOperation(uint32 i) isPublic constant returns(uint32, address, address, string, uint) {
        Operation o = operations[i];
        return (o.id, o.registry, o.performer, o.notes, o.date);
    }

    function setRegistry(address r) isOwner {
        registry = r;
    }

    function makePrivate() isOwner {
        hidden = true;
    }

    function makePublic() isOwner {
        hidden = false;
    }

    function touch() isOwner constant returns(bool) {
        return true;
    }

    modifier isOwner() {
        if (msg.sender != owner) throw;
        _;
    }

    modifier isPublic() {
        if (msg.sender != owner && hidden) throw;
        _;
    }
}
