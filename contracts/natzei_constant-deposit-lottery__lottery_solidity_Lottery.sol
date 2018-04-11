pragma solidity ^0.4.4;

contract Lottery {

    /*
     * structs and enums
     */
    enum State {
        INIT,
        START,
        ABORT,
        WINNER
    }

    struct Player {
        address addr;
        bool refunded;
        bytes32[] secrets;
        uint matchIdx;
    }

    struct MatchData {
        address addr;
        address x;
        address y;
        bytes32 s_x;
        bytes32 s_y;
        address winner;
    }

    /*
     * fields
     */
    uint public N;
    uint public L;
    uint public DEPOSIT;

    uint TIMEOUT_INIT = 5 minutes;
    uint TIMEOUT_TURN_X = 5 minutes;
    uint TIMEOUT_TURN_Y = 5 minutes;

    Player[] players;
    mapping(address => uint) addressToId;

    State public state = State.INIT;
    State public STATE_INIT = State.INIT;       // just to facilitate the status reading
    State public STATE_START = State.START;     // just to facilitate the status reading
    State public STATE_ABORT = State.ABORT;     // just to facilitate the status reading

    uint public level = 0;
    uint start_time = block.timestamp;

    MatchData[] matches;

    uint matchPerLevel;
    uint participantsPerlevel;

    address _lotteryWinner;

    /*
     * modifiers
     */
    modifier atState(State s) {
        if (state!=s) throw;
        _;
    }

    modifier checkDeposit() {
        if (msg.value!=DEPOSIT) throw;
        _;
    }

    modifier checkTimeout(uint t0, uint t, uint delta) {
        if (t-t0<delta) throw;
        _;
    }

    /*
     * events
     */
    // Participant events
    event RegistrationDoneEvent();
    event RegistrationAbortEvent();

    // Monitor events
    event RegistrationEvent(address _addr, uint _userid, bytes32[] _secrets);
    event MatchWinnerEvent(uint _level, uint _matchId, uint _userid);
    event AllRefundedEvent();
    event LevelIncreasedEvent();
    event LotteryWinnerEvent(uint _userid);

    /*
     * constructor
     */
    function Lottery(uint8 _L, uint _deposit) {
        N = 2 ** _L;
        L = _L;
        DEPOSIT = _deposit;
        level = 0;
        participantsPerlevel = N;
        matchPerLevel = N / 2;
    }

    /*
     * functions
     */

    /**
     * Register a new user
     */
    function register(bytes32[] secrets) payable atState(State.INIT) checkDeposit() {

        if (secrets.length!=L) throw;

        /*
         * Initialize the data structure for player i
         */
        uint userid = N-participantsPerlevel;
        addressToId[msg.sender] = userid;

        RegistrationEvent(msg.sender, userid, secrets);

        if (userid%2==0) {   // create a new Match element
            matches.push(MatchData(0,msg.sender,0,secrets[0],0,0));
        }
        else {              // the Match already exists
            MatchData m = matches[matches.length-1];
            m.y = msg.sender;
            m.s_y = secrets[0];
            m.addr = new Match(m.x,m.y,m.s_x,m.s_y,TIMEOUT_TURN_X,TIMEOUT_TURN_Y);
        }

        players.push(Player(
            msg.sender,
            false,
            secrets,
            matches.length-1
        ));

        participantsPerlevel--;

        if (participantsPerlevel==0) { // the lottery can start
            state = State.START;
            RegistrationDoneEvent();
        }
    }

    function timeoutRegistration() checkTimeout(start_time, block.timestamp, TIMEOUT_INIT) atState(State.INIT) {
        state = State.ABORT;
        RegistrationAbortEvent();
    }

    function getMatch() atState(State.START) constant returns(address) {
        return getMatchData().addr;
    }

    function getMatchIdx() atState(State.START) private returns(uint) {
        uint userid = addressToId[msg.sender];
        return players[userid].matchIdx;
    }

    function getMatchData() atState(State.START) private returns(MatchData) {
        return matches[getMatchIdx()];
    }

    function goForward() atState(State.START) {

        /*
         * 1 - verify if the sender is a winner of a match
         */
        MatchData memory m = getMatchData();                // get the last match of the msg.sender
        address matchWinner = Match(m.addr).winner();       // query the contract to get the winner

        if (msg.sender!=matchWinner) throw;                 // only the winner can execute
        if (m.winner!=0) throw;                             // only one invocation is allowed

        m.winner = matchWinner;
        MatchWinnerEvent(level, getMatchIdx(), addressToId[msg.sender]);           // trigger the event

        /*
         * 2 - Prepare the next matches
         */
        if (level+1!=L) {       // if there is another level
            bytes32 secret = getSecretAtLevel(level+1);
            if (matchPerLevel%2==0) {
                matches.push(MatchData(0,msg.sender,0,secret,0,0));
            }
            else {
                MatchData lastMatch = matches[matches.length-1];
                lastMatch.y = msg.sender;
                lastMatch.s_y = secret;
                lastMatch.addr = new Match(
                    lastMatch.x,
                    lastMatch.y,
                    lastMatch.s_x,
                    lastMatch.s_y,
                    TIMEOUT_TURN_X,
                    TIMEOUT_TURN_Y);

                players[addressToId[lastMatch.x]].matchIdx = matches.length-1;
                players[addressToId[lastMatch.y]].matchIdx = matches.length-1;
            }
        }

        /*
         * 3 - if the level is done, go forward to the next level
         */
        matchPerLevel--;                        // count the ended matches

        if (matchPerLevel==0) {                 // all the matches are ended
            level++;
            if (level==L) {                         // lottery is done
                state = State.WINNER;
                _lotteryWinner = matchWinner;
                LotteryWinnerEvent(addressToId[msg.sender]);
                msg.sender.send(this.balance);
            }
            else {                                  // go forward to the next level
                participantsPerlevel = getNumberOfParticipantsPerLevel();
                matchPerLevel = participantsPerlevel / 2;
                LevelIncreasedEvent();
            }
        }
    }

    function getSecretAtLevel(uint level) private returns(bytes32) {
        return players[addressToId[msg.sender]].secrets[level];
    }

    function lotteryWinner() atState(State.WINNER) constant returns(address) {
        return _lotteryWinner;
    }

    /**
     * Refund the participants
     */
    function refund() atState(State.ABORT) {

        uint userid = addressToId[msg.sender];

        // check if the msg.sender was playing
        if (players[userid].addr!=msg.sender) throw;

        // refund it
        if (!players[userid].refunded) {
            players[userid].refunded = true;
            if (!players[userid].addr.send(DEPOSIT)) {
                players[userid].refunded = false;
                throw;
            }
        }

        bool refunded = allRefunded();
        if (refunded)
            AllRefundedEvent();
    }

    function allRefunded() atState(State.ABORT) constant returns(bool) {
        bool allRefunded = true;
        for (uint i=0; i<N-participantsPerlevel; i++) {
            allRefunded = allRefunded && players[i].refunded;
        }
        return allRefunded;
    }

    function getNumberOfParticipantsPerLevel() private returns(uint){
        return 2 ** (L - level);
    }
}

contract Match {

    /*
     * structs and enums
     */
    enum State {X_REVEAL, Y_REVEAL, WINNER}

    /*
     * fields
     */
    State public state = State.X_REVEAL;
    State public STATE_X_REVEAL = State.X_REVEAL;   // just to facilitate the status reading
    State public STATE_Y_REVEAL = State.Y_REVEAL;   // just to facilitate the status reading
    State public STATE_WINNER = State.WINNER;       // just to facilitate the status reading

    address public x;
    address public y;
    bytes32 s_x;    // secret of X
    bytes32 s_y;    // secret of Y
    uint n_x;       // number of X
    uint n_y;       // number of Y

    uint t_x;       // start time of X's turn
    uint t_y;       // start time of Y's turn
    uint TIMEOUT_X;
    uint TIMEOUT_Y;

    address public winnerAddress;
    bool public timeout;

    /*
     * modifiers
     */
    modifier only(address z) {
        if (msg.sender!=z) throw;
        _;
    }

    modifier atState(State s) {
        if (state!=s) throw;
        _;
    }

    modifier checkTimeout(uint t0, uint t, uint delta) {
        if (t-t0<delta) throw;
        _;
    }

    /*
     * events
     */
    event XRevealedEvent(uint number);
    event YRevealedEvent(uint number);
    event WinnerEvent (address winner, bool timeout);

    /*
     * constructor
     */
    function Match(
            address _x,
            address _y,
            bytes32 _s_x,
            bytes32 _s_y,
            uint _timeout_x,
            uint _timeout_y
        ) {
        x = _x;
        y = _y;
        s_x = _s_x;
        s_y = _s_y;
        TIMEOUT_X = _timeout_x;
        TIMEOUT_Y = _timeout_y;
        t_x = block.timestamp;   // start timeout for player X
    }

    /*
     * functions
     */

    function revealX(uint number, uint salt) only(x) atState(State.X_REVEAL) {

        // check the given number
        if (sha3(number,salt)!=s_x) throw;

        n_x = number;
        state = State.Y_REVEAL;
        t_y = block.timestamp;   // start timeout for player Y

        XRevealedEvent(number);
    }

    function revealY(uint number, uint salt) only(y) atState(State.Y_REVEAL){

        // check the given number
        if (sha3(number,salt)!=s_y) throw;

        n_y = number;
        YRevealedEvent(number);
        setWinner();
    }

    function timeoutX() checkTimeout(t_x, block.timestamp, TIMEOUT_X) atState(State.X_REVEAL){
        winnerAddress = y;
        timeout = true;
        state = State.WINNER;
        WinnerEvent(winnerAddress,true);
    }

    function timeoutY() checkTimeout(t_y, block.timestamp, TIMEOUT_Y) atState(State.Y_REVEAL) {
        winnerAddress = x;
        timeout = true;
        state = State.WINNER;
        WinnerEvent(winnerAddress,true);
    }

    function timeoutXEnabled() constant returns (bool) {
        return  state == State.X_REVEAL &&
                block.timestamp - t_x >= TIMEOUT_X;
    }

    function timeoutYEnabled() constant returns (bool) {
        return  state == State.Y_REVEAL &&
                block.timestamp - t_y >= TIMEOUT_Y;
    }

    function setWinner() private {
        if ((n_x+n_y % 2) == 0) winnerAddress = x;
        else winnerAddress = y;
        state = State.WINNER;
        WinnerEvent(winnerAddress,false);
    }

    function winner() constant returns(address) {
        return winnerAddress;
    }
}
