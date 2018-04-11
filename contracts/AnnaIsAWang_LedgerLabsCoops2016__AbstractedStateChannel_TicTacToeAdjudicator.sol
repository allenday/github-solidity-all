import "Adjudicator.sol";
import "TicTacToeLockedState.sol";

/**
 * TicTacToeAdjudicator
 *
 * Adjudicates a TicTacToe game.
 */
contract TicTacToeAdjudicator is Adjudicator {

    /**
     * Creates a new TicTacToeAdjudicator
     *
     * addressX: The address of the X player
     * addressO: The address of the O player
     * _timeout: The amount of time required before the state channel can be closed normally.
     */
    function TicTacToeAdjudicator(address addressX, address addressO, uint _timeout)
        Adjudicator(new address[](2), 2, _timeout)
    {
        addresses = [addressX, addressO];
        lockedState = createLockedState();
    }

    // creates and returns a new TicTacToeLockedState
    function createLockedState() internal returns (LockedState) {
        return new TicTacToeLockedState(addresses[0], addresses[1], 0);
    }
}
