import "StateChannel";

/* Grid is as follows:
 *  0 | 1 | 2
 *  ---------
 *  3 | 4 | 5
 *  ---------
 *  6 | 7 | 8
 *
 * bytes 9 - 28 hold the address of the sender
 */
contract TicTacToe is StateChannel {
    uint constant GRID_SIZE = 3;
    uint constant BLANK = 0;
    uint constant X = BLANK + 1;
    uint constant O = GRID_SIZE + X;
    uint constant X_WIN = X * GRID_SIZE;
    uint constant O_WIN = O * GRID_SIZE;

    function TicTacToe(address x, address o, uint timeout)
        StateChannel(x, o, timeout, new bytes(GRID_SIZE * GRID_SIZE + 20)) {}

    function gridToIndex(uint x, uint y) constant internal returns (uint) {
        return x + GRID_SIZE*y;
    }

    function lastSender() constant internal returns (address) {
        uint160 interimAddress = 0;
        for (uint i = 0; i < 20; i++) {
            interimAddress |= uint160(uint8(_state[i+9]) * 2**(i*8));// why are there no bit-shift operators???
        }
        return address(interimAddress);
    }

    function checkState(bytes state) constant internal returns (bool) {
        uint wins = 0;
        uint sum;
        uint x;
        uint y;

        //check if only valid pieces on the board
        for (x = 0; x < GRID_SIZE * GRID_SIZE; x++) {
            if (_state[x] != byte(BLANK) && _state[x] != byte(X) && _state[x] != byte(O)) {
                return false;
            }
        }

        //checking |
        for (x = 0; x < GRID_SIZE; x++) {
            sum = 0;
            for (y = 0; y < GRID_SIZE; y++) {
                sum += uint(state[gridToIndex(x, y)]);
            }
            if (sum == X_WIN || sum == O_WIN) {
                wins++;
            }
            if (wins > 1) {
                return false;
            }
        }

        //checking -
        for (y = 0; y < GRID_SIZE; y++) {
            sum = 0;
            for (x = 0; x < GRID_SIZE; x++) {
                sum += uint(state[gridToIndex(x, y)]);
            }
            if (sum == X_WIN || sum == O_WIN) {
                wins++;
            }
            if (wins > 1) {
                return false;
            }
        }

        //checking \
        sum = 0;
        for (x = 0; x < GRID_SIZE; x++) {
            sum += uint(state[gridToIndex(x, x)]);
        }
        if (sum == X_WIN || sum == O_WIN) {
            wins++;
        }
        if (wins > 1) {
            return false;
        }

        //checking /
        sum = 0;
        for (x = 0; x < GRID_SIZE; x++) {
            sum += uint(state[gridToIndex(x, GRID_SIZE-1 - x)]);
        }
        if (sum == X_WIN || sum == O_WIN) {
            wins++;
        }
        if (wins > 1) {
            return false;
        }

        return true;
    }

    function finaliseState() internal {
        uint sum;
        uint x;
        uint y;

        //checking |
        for (x = 0; x < GRID_SIZE; x++) {
            sum = 0;
            for (y = 0; y < GRID_SIZE; y++) {
                sum += uint(_state[gridToIndex(x, y)]);
            }
            if (sum == X_WIN) {
                _addressA.send(this.balance);
                return;
            } else if (sum == O_WIN) {
                _addressB.send(this.balance);
                return;
            }
        }

        //checking -
        for (y = 0; y < GRID_SIZE; y++) {
            sum = 0;
            for (x = 0; x < GRID_SIZE; x++) {
                sum += uint(_state[gridToIndex(x, y)]);
            }
            if (sum == X_WIN) {
                _addressA.send(this.balance);
                return;
            } else if (sum == O_WIN) {
                _addressB.send(this.balance);
                return;
            }
        }

        //checking \
        sum = 0;
        for (x = 0; x < GRID_SIZE; x++) {
            sum += uint(_state[gridToIndex(x, x)]);
        }
        if (sum == X_WIN) {
            _addressA.send(this.balance);
            return;
        } else if (sum == O_WIN) {
            _addressB.send(this.balance);
            return;
        }

        //checking /
        sum = 0;
        for (x = 0; x < GRID_SIZE; x++) {
            sum += uint(_state[gridToIndex(x, GRID_SIZE-1 - x)]);
        }
        if (sum == X_WIN) {
            _addressA.send(this.balance);
            return;
        } else if (sum == O_WIN) {
            _addressB.send(this.balance);
            return;
        }

        //checking if there's a tie, if not winner is one who sent transaction
        sum = 0;
        for (x = 0; x < GRID_SIZE * GRID_SIZE; x++) {
            if (_state[x] != byte(BLANK)) {
                sum++;
            }
        }

        if (sum < GRID_SIZE) {
            lastSender().send(this.balance);
            return;
        } else {
            _addressA.send(this.balance / 2);
            _addressB.send(this.balance);
            return;
        }

        //how do you make it so that state of game doesn't have to be sent, only result?
    }
}
