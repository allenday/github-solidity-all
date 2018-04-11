pragma solidity ^0.4.8;

contract LuckyDAO {
    enum Environment {UNDEFINED, PROD, TEST}

    Environment public environment;

    struct Guess {
        uint floor; // start of the guess window
        uint ceil; // end of the guess window = floor + paid wei
    }

    struct Participation {
        mapping(uint8 => Guess) guesses;
        uint8 guessCount;
        uint totalPaid;
    }

    event NewGuess(address participant, uint amount, uint totalPaid, uint floor, uint ceil);
    event GameClosed(uint secret);

    mapping (address => Participation) participations;

    uint public secret;

    uint public endTimeStamp;

    address public redeemer;

/*a mapping of ETH balances for the aprticipants*/
    mapping (uint => address) participants;

    uint public nbParticipants;

/*the constructor expects an endDate in seconds NOT miliseconds from 1970*/
    function LuckyDAO(uint _endTimeStamp, address _redeemer, Environment _environment) {
        environment = _environment;
        endTimeStamp = _endTimeStamp;
        redeemer = _redeemer;
    }

    function setEndTimeStamp(uint _endTimeStamp) {
        if (environment == Environment.TEST) {
            endTimeStamp = _endTimeStamp;
        }
    }

    function computeSecret(uint _secretNum, address _address) constant returns (bytes32) {
        return sha3(_secretNum, _address);
    }

    function getParticipant(uint i) constant returns (address) {
        return participants[i];
    }

/*returns the percent to a 6 digit precision. must be divided by 1'000'000 to get a percentage*/
    function winProbability(address _participant) constant returns (uint) {
        return (participations[_participant].totalPaid * 1000000) / this.balance;
    }

    function getGuessCount(address _participant) constant returns(uint8) {
        return participations[_participant].guessCount;
    }

    function getGuess(address _participant, uint8 i) constant returns(uint floor, uint ceil) {
        Guess guess = participations[_participant].guesses[i];
        return (guess.floor, guess.ceil);
    }

    function isWinner(address _participant) constant returns (bool) {
        for (uint8 i = 0; i < participations[_participant].guessCount; i++) {
            Guess guess = participations[_participant].guesses[i];
            if (secret >= guess.floor && secret < guess.ceil) {
                return true;
            }
        }
        return false;
    }

    function redeem() returns (bool) {
        if(secret != 0){
            return redeemer.send(this.balance);
        }
    }

/*Fallback function for the contract. send ETH to the contract to register*/
    function() payable {
        if (secret == 0 && msg.value > 0) {
            Participation participation = participations[msg.sender];
            if (participation.guessCount == 0) {
                participants[nbParticipants++] = msg.sender;
            }
            Guess guess = participation.guesses[participation.guessCount++];
            guess.floor = this.balance - msg.value;
            guess.ceil = this.balance;
            participation.totalPaid += msg.value;
            NewGuess(msg.sender, msg.value, participation.totalPaid, guess.floor, guess.ceil);
        } else if (secret > 0 && msg.value > 0) {
            bool sent = msg.sender.send(msg.value);
        }

    /*the last participant closes the competition even if the value is 0*/
        if (block.timestamp > endTimeStamp && secret == 0) {
            secret = uint(sha3(block.timestamp, block.blockhash(block.number)
            , block.blockhash(block.number - 1)
            , block.blockhash(block.number - 2)
            , block.blockhash(block.number - 3)
            , block.blockhash(block.number - 4))) % this.balance;

            GameClosed(secret);
        }
    }

}