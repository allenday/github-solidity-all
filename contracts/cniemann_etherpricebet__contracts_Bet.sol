pragma solidity ^0.4.2;

import "./Mortal.sol";

contract Bet is Mortal {
    enum State { New, Open, Closed, Won }

    State public state;
    uint public pricelevel;
    string pricelevel_string;
    address public winner;

    address[] betters;
    mapping (address => uint) public bets;

    event Creation(
        address indexed creator,
        uint indexed price,
        uint jackpot
    );

    event ClosingBetting(
        address indexed creator
    );

    event PlacedBet(
        address indexed creator,
        uint indexed date
    );

    event Payout(
        address indexed creator,
        address indexed winner,
        uint indexed prize
    );

    event DeterminedWinner(
        address indexed winner,
        uint bet,
        uint result,
        uint difference
    );

    event NoWinner( string message);

    event Error( string message);
    event Info( string message );

    function Bet() {
        state = State.New;
    }

    /* interal helper functions */

    // Copyright (c) 2015-2016 Oraclize srl, Thomas Bertani
    function parseInt(string _a, uint _b) internal returns (uint) {
        bytes memory bresult = bytes(_a);
        uint mint = 0;
        bool decimals = false;
        for (uint i = 0; i < bresult.length; i++) {
            if ((bresult[i] >= 48) && (bresult[i] <= 57)) {
                if (decimals) {
                    if (_b == 0) break;
                    else _b--;
                }
                mint *= 10;
                mint += uint(bresult[i]) - 48;
                } else if (bresult[i] == 46) decimals = true;
            }
            return mint;
        }

    function isEmpty(string value) internal returns (bool) {
        if (bytes(value).length == 0) {
            return true;
        }
        return false;
    }

    function create(string price) payable {

        // new bets are only allowed in state State.New
        if (state != State.New) {
            throw;
        }

        winner = 0;
        betters.length = 0;
        pricelevel_string = price;
        pricelevel = parseInt(price, 0);
        state = State.Open;

        Creation(msg.sender, pricelevel, this.balance);
    }

    function hasBet (address better) constant returns (bool) {      
        for (uint i=0; i<betters.length; i++) {
            if (better == betters[i]) {
                return true;
            }
        }
        return false;
    }

    function placeBet (uint date) {

        // bet are allowed during State.Open only
        if (state != State.Open) {
            throw;
        }

        if (!hasBet(msg.sender)) {
            betters.push(msg.sender);
        }

        bets[msg.sender] = date;

        PlacedBet(msg.sender, date);
    }

    function closeBetting() {

        // closing the betting period is allowed during State.Open only
        if (state != State.Open) {
            throw;
        }

        state = State.Closed;

        ClosingBetting(msg.sender);
    }

    function determineWinner(uint result) constant returns(bool, address, uint) {
        address currentWinner;
        uint currentDiff = 999999999999;
        bool foundWinner = false;

        for (uint i=0; i<betters.length; i++) {

            uint difference = 999999999999;

            uint bet = bets[betters[i]];

            if (bet > result) {
                difference = bet - result;
            } else {
                difference = result - bet;
            }

            if (difference < currentDiff) {
                currentDiff = difference;
                currentWinner = betters[i];
                foundWinner = true;
            }
        }
        return (foundWinner, currentWinner, currentDiff);
    }

    function queryOracle(string price) constant {
        //TODO call oracle
        Info("called Bet.queryOracle");
    }

    function evaluateBet() {

        // determine winner is allowed in State.Closed only
        if (state != State.Closed) {
            throw;
        }

        queryOracle(pricelevel_string);
    }

    function evaluateAfterQuery(bool isPriceReached, uint priceDate) returns (bool) {
        if (!isPriceReached) {
            NoWinner('Price has not been reached yet.');
            return false;
        }

        var (foundWinner, winningAddress, difference) = determineWinner(priceDate);

        if (!foundWinner) {
            winner = owner;
            state = State.Won;
            NoWinner('Price has been reached, but there was no bet.');
            return true;
        }

        winner = winningAddress;
        state = State.Won;

        DeterminedWinner(winner, bets[winner], priceDate, difference);
        return true;
    }

    // Callback to be called by once the oracle Query has been resolved
    function __callback(bytes32 myid, string result) public {
        bool isPriceReached = !isEmpty(result);

        evaluateAfterQuery(isPriceReached, parseInt(result, 0));
    }

    function payout() returns (bool) {

        // payout is allowed in State.Won only
        if (state != State.Won) {
            Error('State is not WON');
            throw;
        }

        uint jackpot = this.balance;

        if (winner.send(this.balance)) {
            Payout(msg.sender, winner, jackpot);
            pricelevel = 0;
            state = State.New;
            return true;
        } else {
            Error('Payout failed.');
            return false;
        }
    }
}
