// #include_once "base/permissionsProviderProperty.sol"

contract OwnersDb is PermissionsProviderProperty {
    mapping (address => address) public owners;
    address public ownersTail;
    uint public numOwners;

    function OwnersDb() {
        owners[msg.sender] = msg.sender;
        ownersTail = msg.sender;
        numOwners += 1;
    }

    function addOwner(address newOwner) returns (bool result) {
        if (!senderIsProvider()) return false;
        owners[newOwner] = owners[ownersTail];
        owners[ownersTail] = newOwner;
        ownersTail = newOwner;
        numOwners += 1;
        return true;
    }

    function removeOwner(address owner) returns (bool result) {
        if (owners[owner] == 0x0 || !senderIsProvider()) return false;

        if (ownersTail == owner) {
            ownersTail = owners[owner];
        }

        address iter = owner;

        for (uint i=0; i < numOwners-1; i+=1) {
            iter = owners[iter];
        }

        owners[iter] = owners[owner];
        delete owners[owner];
        numOwners -= 1;
        return true;
    }
}
