/**
 * Owned
 *
 * Inheritable contract that provides onlyOwner modifier.
 */
contract Owned {

    address owner;

    function Owned() {
        owner = msg.sender;
    }

    // only allows the owner to call the function
    modifier onlyOwner {
        if (msg.sender != owner) {
            throw;
        } else {
            _
        }
    }
}
