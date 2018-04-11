import "LockedState.sol";

/**
 * LockedStateWithFunds
 *
 * LockedState which implements the tracking of funds sent to it.
 */
contract LockedStateWithFunds is LockedState {

    // Event triggered whenever funds have been added
    event FundsAdded(address from, address to, uint amount);

    mapping (address => uint) balances;

    /**
     * Gets the balance of the address passed in.
     *
     * toCheck: the address to check the balance for
     * returns: the balance
     */
    function getBalance(address toCheck) constant external notBroadcast returns (uint) {
        return balances[toCheck];
    }

    // Adds funds to the recipient account
    function addFunds(address recipient) notBroadcast {
        balances[recipient] += msg.value;
    }

    // By default, funds are added to the sender's account
    function () {
        addFunds(msg.sender);
    }
}
