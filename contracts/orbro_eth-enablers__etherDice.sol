contract EtherDice {
    uint constant LONG_PHASE = 4;               // blocks
    uint constant SHORT_PHASE = 3;              // blocks
    uint constant HOUSE_EDGE = 2;               // percent
    uint constant SAFEGUARD_THRESHOLD = 3600;   // blocks
    uint constant ARCHIVE_SIZE = 100;           // generations

    uint public minWager = 500 finney;
    uint public maxNumBets = 25;
    uint public bankroll = 0;
    int public profit = 0;

    address public investor;
    uint public investorBankroll = 0;
    int public investorProfit = 0;
    bool public isInvestorLocked = false;

    struct Bet {
        uint id;
        address player;
        uint8 pick;
        bool isMirrored;
        uint wager;
        uint payout;
        uint8 die;
        uint timestamp;
    }

    struct Generation {
        bytes32 seedHashA;
        bytes32 seedHashB;
        bytes32 seedA;
        bytes32 seedB;
        uint minWager;
        uint maxPayout;
        uint ofage;
        uint death;
        uint funeral;
        Bet[] bets;
        bool hasAction;
        Action action;
        int payoutId;
    }

    uint public oldestGen = 0;
    uint public nextGen = 0;
    mapping (uint => Generation) generations;

    address public owner;
    address public seedSourceA;
    address public seedSourceB;

    bytes32 public nextSeedHashA;
    bytes32 public nextSeedHashB;
    bool public hasNextSeedHashA;
    bool public hasNextSeedHashB;

    uint public outstandingPayouts;
    uint public totalBets;

    struct Suitability {
        bool isSuitable;
        uint gen;
    }

    struct ParserResult {
        bool hasResult;
        uint8 pick;
        bool isMirrored;
        uint8 die;
    }

    enum ActionType { Withdrawal, InvestorDeposit, InvestorWithdrawal }

    struct Action {
        ActionType actionType;
        address sender;
        uint amount;
    }

    modifier onlyowner { if (msg.sender == owner) _ }
    modifier onlyseedsources { if (msg.sender == seedSourceA ||
                                   msg.sender == seedSourceB) _ }

    event BetResolved(uint indexed id, uint8 contractDie, bool playerWins);

    function EtherDice(address _seedSourceA, address _seedSourceB) {
        owner = msg.sender;
        seedSourceA = _seedSourceA;
        seedSourceB = _seedSourceB;
        bankroll = msg.value;
    }

    function numberOfHealthyGenerations() returns (uint n) {
        n = 0;
        for (uint i = oldestGen; i < nextGen; i++) {
            if (generations[i].death == 0) {
                n++;
            }
        }
    }

    function needsBirth() constant returns (bool needed) {
        return numberOfHealthyGenerations() < 3;
    }

    function roomForBirth() constant returns (bool hasRoom) {
        return numberOfHealthyGenerations() < 4;
    }

    function birth(bytes32 freshSeedHash) onlyseedsources {
        if (msg.sender == seedSourceA) {
            nextSeedHashA = freshSeedHash;
            hasNextSeedHashA = true;
        } else {
            nextSeedHashB = freshSeedHash;
            hasNextSeedHashB = true;
        }

        if (!hasNextSeedHashA || !hasNextSeedHashB || !roomForBirth()) {
            return;
        }

        // ready to give birth to a new generation
        generations[nextGen].seedHashA = nextSeedHashA;
        generations[nextGen].seedHashB = nextSeedHashB;
        generations[nextGen].minWager = minWager;
        generations[nextGen].maxPayout = (bankroll + investorBankroll) / 100;
        generations[nextGen].ofage = block.number + SHORT_PHASE;
        nextGen += 1;

        hasNextSeedHashA = false;
        hasNextSeedHashB = false;
    }

    function parseMsgData(bytes data) internal constant returns (ParserResult) {
        ParserResult memory result;

        if (data.length != 8) {
            result.hasResult = false;
            return result;
        }

        // parse descriptions like '11-20,01'
        uint8 start = (uint8(data[0]) - 48) * 10 + (uint8(data[1]) - 48);
        uint8 end = (uint8(data[3]) - 48) * 10 + (uint8(data[4]) - 48);
        uint8 die = (uint8(data[6]) - 48) * 10 + (uint8(data[7]) - 48);

        if (start == 1) {
            result.hasResult = true;
            result.pick = end + 1;
            result.isMirrored = false;
            result.die = die;
        } else if (end == 20) {
            result.hasResult = true;
            result.pick = start;
            result.isMirrored = true;
            result.die = die;
        } else {
            result.hasResult = false;
        }

        return result;
    }

    function _parseMsgData(bytes data) constant returns (bool hasResult,
                                                         uint8 pick,
                                                         bool isMirrored,
                                                         uint8 die) {
        ParserResult memory result = parseMsgData(data);

        hasResult = result.hasResult;
        pick = result.pick;
        isMirrored = result.isMirrored;
        die = result.die;
    }

    function () {
        ParserResult memory result = parseMsgData(msg.data);

        if (result.hasResult) {
            bet(result.pick, result.isMirrored, result.die);
        } else {
            bet(11, true,
                toDie(sha3(block.blockhash(block.number - 1), totalBets)));
        }
    }

    function bet(uint8 pick, bool isMirrored, uint8 die) returns (int) {
        if (pick < 2 || pick > 20) {
            msg.sender.send(msg.value);
            return -1;
        }

        if (die < 1 || die > 20) {
            msg.sender.send(msg.value);
            return -1;
        }

        Suitability memory suitability = findSuitableGen();
        uint suitableGen = suitability.gen;

        if (!suitability.isSuitable) {
            msg.sender.send(msg.value);
            return -1;
        }

        if (msg.value < generations[suitableGen].minWager) {
            msg.sender.send(msg.value);
            return -1;
        }

        uint payout = calculatePayout(pick, isMirrored, msg.value);
        if (payout > generations[suitableGen].maxPayout) {
            msg.sender.send(msg.value);
            return -1;
        }

        if (outstandingPayouts + payout > bankroll + investorBankroll) {
            msg.sender.send(msg.value);
            return -1;
        }

        uint idx = generations[suitableGen].bets.length;
        generations[suitableGen].bets.length += 1;
        generations[suitableGen].bets[idx].id = totalBets;
        generations[suitableGen].bets[idx].player = msg.sender;
        generations[suitableGen].bets[idx].pick = pick;
        generations[suitableGen].bets[idx].isMirrored = isMirrored;
        generations[suitableGen].bets[idx].wager = msg.value;
        generations[suitableGen].bets[idx].payout = payout;
        generations[suitableGen].bets[idx].die = die;
        generations[suitableGen].bets[idx].timestamp = now;

        totalBets += 1;
        outstandingPayouts += payout;
        becomeMortal(suitableGen);

        return int(totalBets - 1);  // bet id
    }

    function calculatePayout(uint8 pick, bool isMirrored,
                             uint value) constant returns (uint) {
        // To avoid floating-point math, we work with the house edge
        // scaled by 100 and the betting odds scaled by 1000 and divide
        // the result by 100000.
        uint numWinningOutcomes;
        if (isMirrored) {
            numWinningOutcomes = 21 - pick;
        } else {
            numWinningOutcomes = pick - 1;
        }
        uint payoutFactor = (100 - HOUSE_EDGE) * (20000 / numWinningOutcomes);
        uint payout = (value * payoutFactor) / 100000;
        return payout;
    }

    function becomeMortal(uint gen) internal {
        if (generations[gen].death != 0) {
            return;
        }

        generations[gen].death = block.number + SHORT_PHASE;
    }

    function isSuitableGen(uint gen, uint offset) constant returns (bool) {
        return block.number + offset >= generations[gen].ofage
               && (generations[gen].death == 0
                   || block.number + offset < generations[gen].death)
               && generations[gen].bets.length < maxNumBets;
    }

    function findSuitableGen() internal constant returns (Suitability
                                                          suitability) {
        suitability.isSuitable = false;
        for (uint i = oldestGen; i < nextGen; i++) {
            if (isSuitableGen(i, 0)) {
                suitability.gen = i;
                suitability.isSuitable = true;
                return;
            }
        }
    }

    function needsFuneral(uint offset) constant returns (bool needed) {
        if (oldestGen >= nextGen) {
            return false;
        }

        return generations[oldestGen].death != 0 &&
               generations[oldestGen].death + LONG_PHASE <= block.number + offset;
    }

    function funeral(bytes32 seed, int payoutId) onlyseedsources {
        if (!needsFuneral(0)) {
            return;
        }

        uint gen = oldestGen;
        if (msg.sender == seedSourceA
                && sha3(seed) == generations[gen].seedHashA) {
            generations[gen].seedA = seed;
        } else if (msg.sender == seedSourceB
                        && sha3(seed) == generations[gen].seedHashB) {
            generations[gen].seedB = seed;
        }

        if (sha3(generations[gen].seedA) != generations[gen].seedHashA
                || sha3(generations[gen].seedB) != generations[gen].seedHashB) {
            return;
        }

        // ready to pay out to players and do the funeral
        for (uint i = 0; i < generations[gen].bets.length; i++) {
            uint8 contractDie = toContractDie(generations[gen].seedA,
                                              generations[gen].seedB,
                                              generations[gen].bets[i].id);
            uint8 pick = generations[gen].bets[i].pick;
            bool isMirrored = generations[gen].bets[i].isMirrored;
            uint payout = generations[gen].bets[i].payout;

            bool playerWins = betResolution(contractDie,
                                            generations[gen].bets[i].die,
                                            pick, isMirrored);
            if (playerWins) {
                generations[gen].bets[i].player.send(payout);
            }

            BetResolved(generations[gen].bets[i].id, contractDie, playerWins);
            outstandingPayouts -= payout;

            // profit accounting
            if (investorBankroll >= bankroll) {
                // a sufficiently large investor gets 50 % of the profits
                uint investorShare = generations[gen].bets[i].wager / 2;
                uint ownerShare = generations[gen].bets[i].wager - investorShare;

                investorBankroll += investorShare;
                investorProfit += int(investorShare);
                bankroll += ownerShare;
                profit += int(ownerShare);

                if (playerWins) {
                    investorShare = payout / 2;
                    ownerShare = payout - investorShare;
                    if (ownerShare > bankroll) {
                        ownerShare = bankroll;
                        investorShare = payout - ownerShare;
                    } else if (investorShare > investorBankroll) {
                        investorShare = investorBankroll;
                        ownerShare = payout - investorShare;
                    }

                    investorBankroll -= investorShare;
                    investorProfit -= int(investorShare);
                    bankroll -= ownerShare;
                    profit -= int(ownerShare);
                }
            } else {
                bankroll += generations[gen].bets[i].wager;
                profit += int(generations[gen].bets[i].wager);

                if (playerWins) {
                    bankroll -= payout;
                    profit -= int(payout);
                }
            }
        }
        performAction(gen);

        // make lookup of payout transaction easier
        generations[gen].funeral = block.number;
        generations[gen].payoutId = payoutId;

        // clean up old generations
        oldestGen += 1;
        if (oldestGen >= ARCHIVE_SIZE) {
            delete generations[oldestGen - ARCHIVE_SIZE];
        }
    }

    function performAction(uint gen) internal {
        if (!generations[gen].hasAction) {
            return;
        }

        uint amount = generations[gen].action.amount;
        uint maxWithdrawal;
        if (generations[gen].action.actionType == ActionType.Withdrawal) {
            maxWithdrawal = (bankroll + investorBankroll) - outstandingPayouts;

            if (amount <= maxWithdrawal && amount <= bankroll) {
                owner.send(amount);
                bankroll -= amount;
            }
        } else if (generations[gen].action.actionType ==
                   ActionType.InvestorDeposit) {
            if (investor == 0) {
                investor = generations[gen].action.sender;
                investorBankroll = generations[gen].action.amount;
            } else if (investor == generations[gen].action.sender) {
                investorBankroll += generations[gen].action.amount;
            } else {
                uint investorLoss = 0;
                if (investorProfit < 0) {
                    investorLoss = uint(investorProfit * -1);
                }

                if (amount > investorBankroll + investorLoss) {
                    // better funded investor takes over, but has
                    // to cover potential losses of the previous investor
                    investor.send(investorBankroll + investorLoss);
                    investor = generations[gen].action.sender;
                    investorBankroll = amount - investorLoss;
                    investorProfit = 0;
                } else {
                    // not eligible to become the new investor
                    generations[gen].action.sender.send(amount);
                }
            }
        } else if (generations[gen].action.actionType ==
                   ActionType.InvestorWithdrawal) {
            maxWithdrawal = (bankroll + investorBankroll) - outstandingPayouts;

            if (amount <= maxWithdrawal && amount <= investorBankroll
                    && investor == generations[gen].action.sender) {
                investor.send(amount);
                investorBankroll -= amount;
            }
        }
    }

    function emergencyFuneral() {
        if (generations[oldestGen].death == 0 ||
                block.number - generations[oldestGen].death < SAFEGUARD_THRESHOLD) {
            return;
        }

        // generation did not get a funeral in time - refund everybody
        for (uint i = 0; i < generations[oldestGen].bets.length; i++) {
            uint wager = generations[oldestGen].bets[i].wager;
            uint payout = generations[oldestGen].bets[i].payout;

            generations[oldestGen].bets[i].player.send(wager);
            outstandingPayouts -= payout;
        }
        performAction(oldestGen);

        generations[oldestGen].funeral = block.number;
        generations[oldestGen].payoutId = -1;

        oldestGen += 1;
        if (oldestGen >= ARCHIVE_SIZE) {
            delete generations[oldestGen - ARCHIVE_SIZE];
        }
    }

    function funeralAndBirth(bytes32 seed, int payoutId,
                             bytes32 freshSeedHash) onlyseedsources {
        // combi call to save on transactions
        funeral(seed, payoutId);
        birth(freshSeedHash);
    }

    function lookupGeneration(uint gen) constant returns (bytes32 seedHashA,
                                                          bytes32 seedHashB,
                                                          bytes32 seedA,
                                                          bytes32 seedB,
                                                          uint minWager,
                                                          uint maxPayout,
                                                          uint ofage,
                                                          uint death,
                                                          uint funeral,
                                                          uint numBets,
                                                          bool hasAction,
                                                          int payoutId) {
        seedHashA = generations[gen].seedHashA;
        seedHashB = generations[gen].seedHashB;
        seedA = generations[gen].seedA;
        seedB = generations[gen].seedB;
        minWager = generations[gen].minWager;
        maxPayout = generations[gen].maxPayout;
        ofage = generations[gen].ofage;
        death = generations[gen].death;
        funeral = generations[gen].funeral;
        numBets = generations[gen].bets.length;
        hasAction = generations[gen].hasAction;
        payoutId = generations[gen].payoutId;
    }

    function lookupBet(uint gen, uint bet) constant returns (uint id,
                                                             address player,
                                                             uint8 pick,
                                                             bool isMirrored,
                                                             uint wager,
                                                             uint payout,
                                                             uint8 die,
                                                             uint timestamp) {
        id = generations[gen].bets[bet].id;
        player = generations[gen].bets[bet].player;
        pick = generations[gen].bets[bet].pick;
        isMirrored = generations[gen].bets[bet].isMirrored;
        wager = generations[gen].bets[bet].wager;
        payout = generations[gen].bets[bet].payout;
        die = generations[gen].bets[bet].die;
        timestamp = generations[gen].bets[bet].timestamp;
    }

    function findRecentBet(address player) constant returns (int id, uint gen,
                                                             uint bet) {
        for (uint i = nextGen - 1; i >= oldestGen; i--) {
            for (uint j = generations[i].bets.length - 1; j >= 0; j--) {
                if (generations[i].bets[j].player == player) {
                    id = int(generations[i].bets[j].id);
                    gen = i;
                    bet = j;
                    return;
                }
            }
        }

        id = -1;
        return;
    }

    function toDie(bytes32 data) constant returns (uint8 die) {
        // This turns the input data into a 20-sided die
        // by dividing by ceil(2 ^ 256 / 20). As the input data
        // does not evenly map to 20 values this is actually skewed:
        // Rolling a 20 is around 1e-75 % less likely
        // to occur - we'll live with that.
        uint256 FACTOR = 5789604461865809771178549250434395392663499233282028201972879200395656481997;
        return uint8(uint256(data) / FACTOR) + 1;
    }

    function toContractDie(bytes32 seedA, bytes32 seedB,
                           uint nonce) constant returns (uint8 die) {
        return toDie(sha3(seedA, seedB, nonce));
    }

    function hash(bytes32 data) constant returns (bytes32 hash) {
        return sha3(data);
    }

    function combineDice(uint8 dieA, uint8 dieB) constant returns (uint8 die) {
        die = dieA + dieB;
        if (die > 20) {
            die -= 20;
        }
    }

    function betResolution(uint8 contractDie, uint8 playerDie,
                           uint8 pick, bool isMirrored) constant returns (bool) {
        uint8 die = combineDice(contractDie, playerDie);
        return (isMirrored && die >= pick) || (!isMirrored && die < pick);
    }

    function lowerMinWager(uint _minWager) onlyowner {
        if (_minWager < minWager) {
            minWager = _minWager;
        }
    }

    function raiseMaxNumBets(uint _maxNumBets) onlyowner {
        if (_maxNumBets > maxNumBets) {
            maxNumBets = _maxNumBets;
        }
    }

    function setOwner(address _owner) onlyowner {
        owner = _owner;
    }

    function deposit() onlyowner {
        bankroll += msg.value;
    }

    function withdraw(uint amount) onlyowner {
        Suitability memory suitability = findSuitableGen();
        uint suitableGen = suitability.gen;

        if (!suitability.isSuitable) {
            return;
        }

        if (generations[suitableGen].hasAction) {
            return;
        }

        generations[suitableGen].action.actionType = ActionType.Withdrawal;
        generations[suitableGen].action.amount = amount;
        generations[suitableGen].hasAction = true;
        becomeMortal(suitableGen);
    }

    function investorDeposit() {
        if (isInvestorLocked && msg.sender != investor) {
            return;
        }

        Suitability memory suitability = findSuitableGen();
        uint suitableGen = suitability.gen;

        if (!suitability.isSuitable) {
            return;
        }

        if (generations[suitableGen].hasAction) {
            return;
        }

        generations[suitableGen].action.actionType = ActionType.InvestorDeposit;
        generations[suitableGen].action.sender = msg.sender;
        generations[suitableGen].action.amount = msg.value;
        generations[suitableGen].hasAction = true;
        becomeMortal(suitableGen);
    }

    function investorWithdraw(uint amount) {
        Suitability memory suitability = findSuitableGen();
        uint suitableGen = suitability.gen;

        if (!suitability.isSuitable) {
            return;
        }

        if (generations[suitableGen].hasAction) {
            return;
        }

        generations[suitableGen].action.actionType = ActionType.InvestorWithdrawal;
        generations[suitableGen].action.sender = msg.sender;
        generations[suitableGen].action.amount = amount;
        generations[suitableGen].hasAction = true;
        becomeMortal(suitableGen);
    }

    function setInvestorLock(bool _isInvestorLocked) onlyowner {
        isInvestorLocked = _isInvestorLocked;
    }

    function setSeedSourceA(address _seedSourceA) {
        if (msg.sender == seedSourceA || seedSourceA == 0) {
            seedSourceA = _seedSourceA;
        }
    }

    function setSeedSourceB(address _seedSourceB) {
        if (msg.sender == seedSourceB || seedSourceB == 0) {
            seedSourceB = _seedSourceB;
        }
    }
}