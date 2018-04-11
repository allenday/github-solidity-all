contract Owned {
    address public owner;

    function Owned() {
        owner = msg.sender;
    }

    function setOwner(address newOwner) returns (bool result) {
        if (msg.sender != owner) return false;
        owner = newOwner;
        return true;
    }
}
