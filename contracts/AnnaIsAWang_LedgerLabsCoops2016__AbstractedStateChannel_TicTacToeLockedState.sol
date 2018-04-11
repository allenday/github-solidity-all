import "LockedStateWithFunds.sol";

/**
 * TicTacToeLockedState
 *
 * The LockedState for a TicTacToe game.
 */
contract TicTacToeLockedState is LockedState {

    /* bit mappings for state
     * 0: X gets winnings
     * 1: O gets winnings
     * 2: X forfeits adjudication deposit
     * 3: O forfeits adjudication deposit
     * 4: X forfeits disconnect deposit
     * 5: O forfeits disconnect deposit
     * 6: state should be immutable, useful for cheating-related scenarios
     * note, if tie, bits 0 and 1 should both be 0 to indicate tie
     */
    address addressX;
    address addressO;
    address burner;

    uint[6] funds;

    /**
     * addressX: the address of X
     * addressO: the address of O
     * burner: the address which funds will be burned to (usually 0)
     */
    function TicTacToeLockedState(address _addressX, address _addressO, address _burner) {
        addressX = _addressX;
        addressO = _addressO;
        burner = _burner;
    }

    /*
     * Deposits funds into an escrow account.
     *
     * Accounts are as follows:
     * 0: X's bet
     * 1: O's bet
     * 2: X's adjudication deposit
     * 3: O's adjudication deposit
     * 4: X's disconnect deposit
     * 5: O's disconnect deposit
     */
    function deposit(uint account) external notBroadcast {
        if (account >= 6) {
            throw;
        } else {
            funds[account] += msg.value;
        }
    }

    /**
     * Returns the balance of the account corresponding to the above.
     */
    function getBalance(uint account) constant external notBroadcast returns (uint) {
        if (account >= 6) { throw;
        } else {
            return funds[account];
        }
    }

    /**
     * Checks if a given state is valid.
     * Must be a bytes1 that holds the specified values above.
     * Bits 0 and 1 must not both be 1.
     *
     * state: the state to check
     * returns: true if the state is valid, otherwise false
     */
    function checkState(bytes state) constant returns (bool) {
        if (state.length == 1) {
            return uint8(state[0]) & 0x03 != 0x03;
        } else {
            return false;
        }
    }

    /**
     * Splits the funds according to the state.
     *
     * state: the state that will be broadcast
     * returns: true if transaction sent sucessfully, otherwise false
     */
    function broadcastState(bytes state) external onlyOwner notBroadcast returns (bool) {
        if (!checkState(state)) {
            return false;
        }

        uint sendToX = 0;
        uint sendToO = 0;

        uint uintState = uint(state[0]);

        if (uintState & 0x03 == 0x01) {// X wins, gets bet
            sendToX += funds[0] + funds[1];
        } else if (uintState & 0x03 == 0x02) {// O wins, gets bet
            sendToO += funds[0] + funds[1];
        } else {// tie, they get individual bets back
            sendToX += funds[0];
            sendToO += funds[1];
        }

        // checks if funds should be forfeited
        sendToX += (uintState & 0x04 == 0x00 ? funds[2] : 0) + (uintState & 0x10 == 0x00 ? funds[4] : 0);
        sendToO += (uintState & 0x08 == 0x00 ? funds[3] : 0) + (uintState & 0x20 == 0x00 ? funds[5] : 0);

        broadcast = true;

        if (!addressX.send(sendToX)) {
            throw;
        }

        if (!addressO.send(sendToO)) {
            throw;
        }

        // burns the remaining funds
        if (!burner.send(this.balance)) {
            throw;
        }

        return true;
    }

    // funds should only be sent through the deposit method
    function () {
        throw;
    }
}
