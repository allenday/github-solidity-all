import "Rules.sol";
import "TicTacToeAdjudicator.sol";

/* Board state values are as follows:
 *  0 | 1 | 2
 *  ---------
 *  3 | 4 | 5
 *  ---------
 *  6 | 7 | 8
 *
 * 9: 4 if last player was O, 1 if the last player was X
 */
contract TicTacToeRules is Rules {

    event StateSent(bytes state);
    event Cheating(address cheater);
    event BoardWinner(address winner);
    event CheckedIn();

    uint constant BLANK = 0;
    uint constant X = 1;
    uint constant O = 4;

    address addressX;
    address addressO;
    uint timeout;

    /**
     * Creates a new TicTacToeRules
     * _addressX: the address of X
     * _addressO: the address of O
     * _timeout: the timeout before state can be closed
     */
    function TicTacToeRules(address _addressX, address _addressO, uint _timeout) {
        addressX = _addressX;
        addressO = _addressO;
        timeout = _timeout;
        adjudicator = createAdjudicator();
    }

    function createAdjudicator() internal returns (Adjudicator newAdjudicator) {
        newAdjudicator = new TicTacToeAdjudicator(addressX, addressO, timeout);
        delete timeout;
    }

    // Converts a grid coordinate to an index value
    function gridToIndex(uint x, uint y) constant internal returns (uint) {
        return x + 3*y;
    }

    /**
     * Send a state directly to the underlying state channel.
     * Allows for transactions to be closed without any adjudication fees.
     *
     * state: the state that will be sent
     * nonce: the nonce that will be sent
     * the rest are signature values for X and O, respectively
     * returns: true if state sent sucessfully, otherwise false
     */
    function sendState(
        bytes state,
        uint nonce,
        uint8 vX,
        bytes32 rX,
        bytes32 sX,
        uint8 vO,
        bytes32 rO,
        bytes32 sO
    ) external returns (bool) {
        uint8[] memory v = new uint8[](2);
        bytes32[] memory r = new bytes32[](2);
        bytes32[] memory s = new bytes32[](2);

        v[0] = vX;
        v[1] = vO;
        r[0] = rX;
        r[1] = rO;
        s[0] = sX;
        s[1] = sO;

        if (adjudicator.close(2, state, nonce, v, r, s)) {
            StateSent(state);
            return true;
        } else {
            return false;
        }
    }

    /**
     * Sends a unilateral ruling (0 signatures required) to underlying adjudicator.
     *
     * uintState: the state which will be sent
     * nonce: the nonce which will be sent
     * returns: true if the state was sent successfully, otherwise false
     */
    function unilateralRuling(uint8 uintState, uint nonce) internal returns (bool) {
        bytes memory state = new bytes(1);
        state[0] = byte(uintState);
        adjudicator.close(0, state, nonce, new uint8[](1), new bytes32[](1), new bytes32[](1));
    }

    /**
     * Sends a board to be adjudicated upon.
     *
     * board: the board to be adjudicated upon
     * nonce: the nonce that will be used
     * v, r, s: X's signature if last player was X, O's signature if last player was O
     * returns: true if adjudication was sucessful, otherwise false
     */
    function sendBoard(
        bytes10 board,
        uint nonce,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (bool) {
        uint x;
        uint y;
        uint i;
        uint8 uintState = uint(board[9]) == X ? 0x28 : 0x14;// by default, the person who didn't play will lose all deposits

        if (
            !((uint(board[9]) == X && addressX == ecrecover(sha3(board, nonce, address(this)), v, r, s))
            || (uint(board[9]) == O && addressO == ecrecover(sha3(board, nonce, address(this)), v, r, s)))
        ) {
            return false;
        }

        // checking wins
        // checking |
        for (x = 0; x < 3; x++) {
            i = 0;
            for (y = 0; y < 3; y++) {
                i += uint(board[gridToIndex(x, y)]);
            }
            if (i == X * 3) {
                if (unilateralRuling(uintState | 0x01, nonce)) {// give X the bet winnings
                    BoardWinner(addressX);
                    return true;
                } else {
                    return false;
                }
            } else if (i == O * 3) {
                if (unilateralRuling(uintState | 0x02, nonce)) {// give O the bet winnings
                    BoardWinner(addressO);
                    return true;
                } else {
                    return false;
                }
            }
        }

        // checking -
        for (y = 0; y < 3; y++) {
            i = 0;
            for (x = 0; x < 3; x++) {
                i += uint(board[gridToIndex(x, y)]);
            }
            if (i == X * 3) {
                if (unilateralRuling(uintState | 0x01, nonce)) {
                    BoardWinner(addressX);
                    return true;
                } else {
                    return false;
                }
            } else if (i == O * 3) {
                if (unilateralRuling(uintState | 0x02, nonce)) {
                    BoardWinner(addressO);
                    return true;
                } else {
                    return false;
                }
            }
        }

        // checking \
        i = 0;
        for (x = 0; x < 3; x++) {
            i += uint(board[gridToIndex(x, x)]);
        }
        if (i == X * 3) {
            if (unilateralRuling(uintState | 0x01, nonce)) {
                BoardWinner(addressX);
                return true;
            } else {
                return false;
            }
        } else if (i == O * 3) {
            if (unilateralRuling(uintState | 0x02, nonce)) {
                BoardWinner(addressO);
                return true;
            } else {
                return false;
            }
        }

        // checking /
        i = 0;
        for (x = 0; x < 3; x++) {
            i += uint(board[gridToIndex(x, 2 - x)]);
        }
        if (i == X * 3) {
            if (unilateralRuling(uintState | 0x01, nonce)) {
                BoardWinner(addressX);
                return true;
            } else {
                return false;
            }
        } else if (i == O * 3) {
            if (unilateralRuling(uintState | 0x02, nonce)) {
                BoardWinner(addressO);
                return true;
            } else {
                return false;
            }
        }

        // check if tie
        for (i = 0; i < 9; i++) {
            if (uint(board[i]) == BLANK) {
                // last player wins
                if (unilateralRuling(uintState | (uint(board[9]) == X ? 0x01 : 0x02), nonce)) {// bets sent to last player
                    BoardWinner(uint(board[9]) == X ? addressX : addressO);
                    return true;
                } else {
                    return false;
                }
            }
        }
        // it is a tie
        if (unilateralRuling(uintState, nonce)) {// if tie, bets returned
            BoardWinner(0);
            return true;
        } else {
            return false;
        }
    }

    /**
     * Punishes a sender for sending an errornous board.
     *
     * oldBoard: the old board to be compared against
     * oldNonce: the old nonce to verify the old board
     * oldV, oldR, oldS: the signature for oldBoard, from the last player
     * newBoard: the new board which has an error
     * newNonce: the new nonce of newBoard
     * newV, newR, newS: the signatures for newBoard, from the last player
     */
    function badBoardSent(
        bytes10 oldBoard,
        uint oldNonce,
        uint8 oldV,
        bytes32 oldR,
        bytes32 oldS,
        bytes10 newBoard,
        uint newNonce,
        uint8 newV,
        bytes32 newR,
        bytes32 newS
    ) external returns (bool) {
        address signer = uint(newBoard[9]) == X ? addressX : addressO;
        // verify the integrity of the boards
        if (
            oldNonce >= newNonce ||
            !(signer == ecrecover(sha3(oldBoard, oldNonce, address(this)), oldV, oldR, oldS) &&
            signer == ecrecover(sha3(newBoard, newNonce, address(this)), newV, newR, newS))
        ) {
            return false;
        }

        bool notChanged = true;
        for (uint i = 0; i < 9; i++) {
            if (oldBoard[i] == newBoard[i]) {
                continue;
            }
            if ((uint(newBoard[i]) == X || uint(newBoard[i]) == O) && (uint(oldBoard[i]) == BLANK) && notChanged && (newBoard[i] == newBoard[9])) {
                notChanged = false;
                continue;
            }
            // shenanigans
            if (unilateralRuling(uint(newBoard[9]) == X ? 0x5E : 0x6D, newNonce)) {
                Cheating(uint(newBoard[9]) == X ? addressX : addressO);
                return true;
            } else {
                return false;
            }
        }
        if (notChanged && unilateralRuling(uint(newBoard[9]) == X ? 0x5E : 0x6D, newNonce)) {
            // shenanigans
            Cheating(uint(newBoard[9]) == X ? addressX : addressO);
            return true;
        } else {
            // nothing fishy
            return false;
        }
    }

    /**
     * Lets the contract know that you have not disconnected.
     * Will modify the state such that the disconnect deposits will be
     * refunded and both party's adjudication deposits will be lost.
     *
     * returns: true if sucessful, otherwise false
     */
    function checkIn() external returns (bool) {
        uint8 uintState = uint8(adjudicator.getStateAt(0));

        // does not work if someone has cheated or if adjudicator wasn't used
        if (uintState & 0x40 != 0x00 || uintState & 0x3C == 0x00) {
            return false;
        }
        if (unilateralRuling(uintState & 0xCF | 0x0C, adjudicator.getNonce())) {
            CheckedIn();
            return true;
        } else {
            return false;
        }
    }

    /**
     * Kills contract and child contracts.
     *
     * recipient: recipient of killed contract funds
     * vX, rX, sX: signature values for X
     * vO, rO, sO: signature values for O
     */
    function kill(
        address recipient,
        uint8 vX,
        bytes32 rX,
        bytes32 sX,
        uint8 vO,
        bytes32 rO,
        bytes32 sO
    ) external {
        bytes32 hash = sha3(recipient, address(this));
        if (addressX == ecrecover(hash, vX, rX, sX) &&
            addressO == ecrecover(hash, vO, rO, sO)) {
            adjudicator.kill();
            selfdestruct(recipient);
        }
    }
}
