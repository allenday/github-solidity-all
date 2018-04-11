pragma solidity ^0.4.2;

contract Roulette {
    uint public nextRoundTimestamp;
    uint _interval;
    address _owner;

    enum BetType { Single, Odd, Even }
    struct Bet {
        BetType betType;
        address player;
        uint number;
        uint value;
    }
    Bet[] public bets;

    event Finished(uint number, uint nextRoundTimestamp);
    event NewSingleBet(uint bet, address player, uint number, uint value);
    event NewEvenBet(uint bet, address player, uint value);
    event NewOddBet(uint bet, address player, uint value);
    
    function Roulette(uint interval) payable {
	    _interval = interval;
	    _owner = msg.sender;
	    nextRoundTimestamp = now + _interval;
    }

    function getNextRoundTimestamp() public constant returns(uint) {
        return nextRoundTimestamp;
    }

    function getBetsCountAndValue() public constant returns(uint, uint) {
        uint value = 0;
        for (uint i = 0; i < bets.length; i++) {
            value += bets[i].value;
        }
        return (bets.length, value);
    }

    function betSingle(uint number) payable public transactionMustContainEther() bankMustBeAbleToPayForBetType(BetType.Single) {
        if (number > 36) throw;
        bets.push(Bet({
            betType: BetType.Single,
            player: msg.sender,
            number: number,
            value: msg.value
        }));
        NewSingleBet(bets.length,msg.sender,number,msg.value);
    }

    function betEven() payable public transactionMustContainEther() bankMustBeAbleToPayForBetType(BetType.Even) {
        bets.push(Bet({
            betType: BetType.Even,
            player: msg.sender,
            number: 0,
            value: msg.value
        }));
        NewEvenBet(bets.length,msg.sender,msg.value);
    }

    function betOdd() payable public transactionMustContainEther() bankMustBeAbleToPayForBetType(BetType.Even) {
        bets.push(Bet({
            betType: BetType.Odd,
            player: msg.sender,
            number: 0,
            value: msg.value
        }));
        NewOddBet(bets.length,msg.sender,msg.value);
    }

    function launch() public {
        if (now < nextRoundTimestamp) throw;

        uint number = uint(block.blockhash(block.number - 1)) % 37;
        
        for (uint i = 0; i < bets.length; i++) {
            bool won = false;
            uint payout = 0;
            if (bets[i].betType == BetType.Single) {
                if (bets[i].number == number) {
                    won = true;
                }
            } else if (bets[i].betType == BetType.Even) {
                if (number > 0 && number % 2 == 0) {
                    won = true;
                }
            } else if (bets[i].betType == BetType.Odd) {
                if (number > 0 && number % 2 == 1) {
                    won = true;
                }
            }
            if (won) {
                if (!bets[i].player.send(bets[i].value * getPayoutForType(bets[i].betType))) {
                    throw;
                }
            }
        }

        uint thisRoundTimestamp = nextRoundTimestamp;
        nextRoundTimestamp = thisRoundTimestamp + _interval;

        bets.length = 0;

        Finished(number, nextRoundTimestamp);
    }

    function getPayoutForType(BetType betType) constant returns(uint) {
        if (betType == BetType.Single) return 35;
        if (betType == BetType.Even || betType == BetType.Odd) return 2;
        return 0;
    }

    modifier transactionMustContainEther() {
        if (msg.value == 0) throw;
        _;
    }

    modifier bankMustBeAbleToPayForBetType(BetType betType) {
        uint necessaryBalance = 0;
        for (uint i = 0; i < bets.length; i++) {
            necessaryBalance += getPayoutForType(bets[i].betType) * bets[i].value;
        }
        necessaryBalance += getPayoutForType(betType) * msg.value;
        if (necessaryBalance > this.balance) throw;
        _;
    }
}