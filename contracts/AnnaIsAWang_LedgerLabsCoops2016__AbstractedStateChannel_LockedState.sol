import "Owned.sol";

/**
 * LockedState
 *
 * Abstract contract in which all externally modifiable state should be stored.
 * Should be initialised by some Adjudicator contract.
 */
contract LockedState is Owned {

    // indicates whether the LockedState has been broadcast
    bool broadcast = false;

    // throw if the method has been broadcast before
    modifier notBroadcast {
        if (broadcast) {
            throw;
        } else {
            _
        }
    }

    // an abstract method to check if the final state is valid
    function checkState(bytes state) constant returns (bool);

    // broadcasts the final state to the blockchain
    // it is onlyOwner because this contract should be initialised and controlled by an Adjudicator
    function broadcastState(bytes state) external onlyOwner notBroadcast returns (bool);

    // kills the contract
    function kill() external onlyOwner {
        selfdestruct(owner);
    }
}
