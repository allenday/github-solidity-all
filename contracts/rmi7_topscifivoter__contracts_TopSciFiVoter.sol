pragma solidity ^0.4.11; // TODO: change to static version when deploying on mainnet

import "zeppelin-solidity/contracts/math/SafeMath.sol";
import "zeppelin-solidity/contracts/ownership/Ownable.sol";
import "zeppelin-solidity/contracts/ReentrancyGuard.sol";

/**
 * @title TopSciFiVoter
 * @dev is a contract to vote on Science Fiction movies, although the existence
 * of a movie name is not verified. The amount of ether needed to place a vote
 * is 1 ETH, any excess amount will immediately be refunded to the sender.
 * When the voting round has ended all voters can withdraw their bids.
 */
contract TopSciFiVoter is Ownable, ReentrancyGuard {
    using SafeMath for uint256;

    // the max time (in days) of a voting round
    // cannot do * 1 days here since not all days are 24 hours, so this depends
    // on the time in a year that it's called/needed (so at runtime).
    uint256 private constant ROUND_MAX_DAYS = 30; // days

    // the amount of ETH needed to place 1 vote
    uint256 private constant VOTE_PRICE = 1 ether;

    // the timestamp of when the vote starts
    uint256 public begin;

    // the timestamp of when the vote ends
    uint256 public end;

    // keep track of the number of movies
    uint256 public movieCount;

    // list of all current movies that have been voted on
    // NOTE: movie names are not verified so any (max 32 bytes = 32 ascii characters)
    //       string can be voted on
    bytes32[] public movies;

    // enum to keep track of the status of the voting round
    enum Status { NotStarted, Active, Ended }

    // current status of the voting round
    Status public status;

    // keep track of the bids per address so that they can be withdrawn after the
    // voting round has ended
    mapping(address => uint256) private pendingReturns;

    // map of address to amount of ETH in bids
    mapping(bytes32 => uint256) public bids;

    // keep mapping to check that one address has only voted once ona movie
    mapping(address => mapping(bytes32 => bool)) private votedOn;

    /**
     * event indicates voting round status is now 'Active'
     */
    event LogVoteStarted();

    /**
     * event indicates voting round status is now 'Ended'
     */
    event LogVoteEnded();

    /**
     * event indicates somebody voted
     * @param voter who placed a vote
     * @param movieName that was voted on
     */
    event LogNewVote(address indexed voter, bytes32 indexed movieName);

    /**
     * event indicates somebody withdrew his bid after the voting round ended
     * @param voter who placed a vote
     * @param amount that was withdrawn
     */
    event LogWithdrawn(address indexed voter, uint256 amount);

    // check that voting round status is in a specific state
    modifier statusIs(Status wantedStatus) {
        /*bool changedToEnded = false;*/

        if (status == Status.Active && now >= end) {
            // since the voting round ends at a specific time, everytime this modifier
            // is used first check the current status. If it's Active, check if the
            // current timestamp is greater than the end timestamp. If it is it means
            // the voting round just ended and we need to change the status to Ended.
            status = Status.Ended;

            /*changedToEnded = true;*/
        }
        require(status == wantedStatus);
        _;
        // we can only get here if wantedStatus == Status.Ended
        /*if (changedToEnded) {
            LogVoteEnded();
        }*/
    }

    // check that msg value is at least the VOTE_PRICE,
    // and will refund the amount higher than the VOTE_PRICE to the sender
    modifier amountHighEnough {
        require(msg.value >= VOTE_PRICE);
        _;
    }

    // check that sender has pending returns
    modifier hasPendingReturns {
        require(pendingReturns[msg.sender] > 0);
        _;
    }

    modifier validEndTime(uint256 endTime) {
        require(endTime > now);

        // endTime needs to be smaller than the maximum allowed end time (defined in days)
        require(endTime <= now + ROUND_MAX_DAYS * 1 days);
        _;
    }

    modifier onlyOneVotePerMoviePerSender(bytes32 movieName) {
        require(votedOn[msg.sender][movieName] == false);
        _;
    }

    function TopSciFiVoter() {
        movieCount = 0;
        status = Status.NotStarted;
    }

    /**
     * @dev start the voting period, initiated by the owner of the contract
     * NOTE: why thi is not in the constructor?
     * - truffle (currently) does not support solidity tests with a constructor with params
     * - by maing it a separate function the owner can on a lter date start the vote instead
     *   of at the moment the contract is deployed on the chain
     */
    function start(uint256 endTime)
        external
        onlyOwner
        statusIs(Status.NotStarted)
        validEndTime(endTime)
    {
        begin = now;
        end = endTime;
        status = Status.Active;
        LogVoteStarted();
    }

    /**
     * @dev vote on a supplied movie name, amount to vote is 1 ETH, excess will be refunded
     * @param movieName of the movie to bet on
     */
    function vote(bytes32 movieName)
        external
        payable
        statusIs(Status.Active)
        amountHighEnough
        onlyOneVotePerMoviePerSender(movieName)
        nonReentrant
    {
        if (bids[movieName] == 0) {
            // movie does not yet exist(= has not been voted on)

            // if this function is called many many many times, movieCount
            // could overflow, therefore use SafeMath.add
            movieCount = movieCount.add(1);

            // add movie to list of voted on movies
            movies.push(movieName);
        }

        // since VOTE_PRICE is constant, and amountHighEnough check amount is high enough
        // we can just add VOTE_PRICE here (the excess amount is handled at the bottom of
        // this function)
        // if this function is called many many many times, bids[name] and pendingReturns[msg.sender]
        // could overflow, therefore use SafeMath.add
        bids[movieName] = bids[movieName].add(VOTE_PRICE);
        pendingReturns[msg.sender] = pendingReturns[msg.sender].add(VOTE_PRICE);

        // set votedOn to true to indicate this sender has voted on this movie,
        // any address can only vote once on a movie
        votedOn[msg.sender][movieName] = true;

        // send event somebody placed a vote
        LogNewVote(msg.sender, movieName);

        if (msg.value > VOTE_PRICE) {
            // immediately refund the excess amount

            // no need for SafeMath since:
            // - amountHighEnough already checks that amount is high enough
            // - the if condition checked that amount > VOTE_PRICE
            // so save the gas and don't use SafeMath.sub
            msg.sender.transfer(msg.value - VOTE_PRICE);
        }
    }

    /**
     * @dev withdraw all placed bids of the sender
     */
    function withdraw()
        external
        statusIs(Status.Ended)
        hasPendingReturns
        nonReentrant
    {
        // get the amount the sender can withdraw
        uint256 amount = pendingReturns[msg.sender];

        // update the saved amount to withdraw to zero
        pendingReturns[msg.sender] = 0;

        // send the amount to the sender
        msg.sender.transfer(amount);

        // send event somebody withdrew his bid(s)
        LogWithdrawn(msg.sender, amount);
    }

    /**
     * @dev returns the current status of the voting round
     * just calling status() will not look if the time of the voting round
     * has passed, that's why this function exists!
     */
    function getStatus()
        constant
        returns (Status)
    {
        if (status == Status.Active && now <= end) {
            return Status.Active;
        } else if (status == Status.Ended || now <= end) {
            return Status.Ended;
        } else {
            return Status.NotStarted;
        }
    }
}
