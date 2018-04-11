import "AmbiEnabled.sol";
import "ElcoinDb.sol";

contract ElcoinInterface {
    function rewardTo(address _to, uint _amount) returns (bool);
}

contract PotRewards is AmbiEnabled {

    event Reward(address indexed beneficiary, uint indexed round, uint value, uint position);

    struct Transaction {
        address from;
        uint amount;
    }

    uint public round = 0;
    uint public counter = 0;            //counts each transaction
    Transaction[] public transactions;  //records details of txns participating in next auction round

    //parameters
    uint public periodicity;        //how often does an auction happen (ie. each 10000 tx)
    uint8 public auctionSize;       //how many transactions participate in auction
    uint public prize;              //total amount of prize for each round
    uint public minTx;              //transactions less than this amount will not be counted
    uint public startTime;          //starting at startTime to calculate double rewards

    ElcoinInterface public elcoin;  //contract to do rewardTo calls

    function configure(uint _periodicity, uint8 _auctionSize, uint _prize, uint _minTx, uint _counter, uint _startTime) checkAccess("owner") returns (bool) {
        if (_auctionSize > _periodicity || _prize == 0 || _auctionSize > 255) {
            return false;
        }
        periodicity = _periodicity;
        auctionSize = _auctionSize;
        prize = _prize;
        minTx = _minTx;
        counter = _counter;
        startTime = _startTime;
        elcoin = ElcoinInterface(getAddress("elcoin"));
        return true;
    }

    function transfer(address _from, address _to, uint _amount) checkAccess("elcoin") {
        if (startTime > now || periodicity == 0 || auctionSize == 0 || prize == 0) {
            return;
        }
        counter++;
        if (_amount >= minTx && counter > periodicity - auctionSize) {
            transactions.push(Transaction(_from, _amount));
        }

        if (counter >= periodicity) {
            _prepareAndSendReward();
            counter = 0;
            round++;
            delete transactions;
        }
    }

    mapping(uint => mapping(address => uint)) public prizes;

    function _prepareAndSendReward() internal {
        uint amount = 0;
        address[] memory winners = new address[](auctionSize);
        uint winnerPosition = 0;
        for (uint8 i = 0; i < transactions.length; i++) {
            if (transactions[i].amount == amount) {
                winners[winnerPosition++] = transactions[i].from;
            }
            if (transactions[i].amount > amount) {
                amount = transactions[i].amount;
                winnerPosition = 0;
                winners[winnerPosition++] = transactions[i].from;
            }
        }
        if (winnerPosition == 0) {
            return;
        }
        address[] memory uniqueWinners = new address[](winnerPosition);
        uint uniqueWinnerPosition = 0;
        uint currentPrize = _is360thDay() ? prize*2 : prize;
        uint reward = currentPrize / winnerPosition;
        for (uint8 position = 0; position < winnerPosition; position++) {
            address winner = winners[position];
            if (prizes[round][winner] == 0) {
                uniqueWinners[uniqueWinnerPosition++] = winner;
            }
            prizes[round][winner] += reward;
        }
        for (position = 0; position < uniqueWinnerPosition; position++) {
            winner = uniqueWinners[position];
            uint winnerReward = prizes[round][winner];
            if (elcoin.rewardTo(winner, winnerReward)) {
                Reward(winner, round, winnerReward, position);
            }
        }
    }

    function _is360thDay() internal constant returns(bool) {
        if (startTime > now) {
            return false;
        }

        return (((now - startTime) / 1 days) + 1) % 360 == 0;
    }
}