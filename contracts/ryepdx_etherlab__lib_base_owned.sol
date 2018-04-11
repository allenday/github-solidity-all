contract Owned {
    address public owner;

    function Owned() {
        owner = msg.sender;
    }

    function setOwner(address newOwner) {
        if (msg.sender != owner) return;
        owner = newOwner;
    }
}
