pragma solidity ^0.4.11;

contract owned {
    address owner;

    modifier isOwned() {
        if (msg.sender == owner) {
            _;
        }
    }
    function owned() {
        owner = msg.sender;
    }
    function modifyOwner() isOwned {
        owner = msg.sender;
    }
}
contract mortal is owned {
    function kill() isOwned {
        selfdestruct(owner);
    }
}
contract RefID is owned, mortal {
    
    struct Location {
        string lat;
        string long;
        uint dateAdded;
    }

    struct Person {
        bytes32 bioHash;
        uint dateUpdated;
        uint dateCreated;
        address addr;
        Location[] locations;
    }
    
    Person person;
    
    function RefID(string _lat, string _long) {
        owner = msg.sender;
        person.addr = msg.sender;
        person.dateUpdated = now;
        person.dateCreated = now;
        person.locations.push(Location(_lat, _long, now));
    }
    
    function hashBiometricTemplates(string _fingerPrint, string _faceRecon, string _iris) isOwned {
        person.bioHash = sha256(_fingerPrint, _faceRecon, _iris);
        person.dateUpdated = now;
    }
    
    function getPerson() constant returns (bytes32, address, uint, uint) {
        return (person.bioHash, person.addr, person.dateUpdated, person.dateCreated);
    }
    
    function updateLocation(string _lat, string _long) {
        person.locations.push(Location(_lat, _long, now));
    }
}