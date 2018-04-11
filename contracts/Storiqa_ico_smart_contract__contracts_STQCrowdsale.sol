pragma solidity 0.4.15;

import './ownership/multiowned.sol';
import './crowdsale/FixedTimeBonuses.sol';
import './crowdsale/FundsRegistry.sol';
import './crowdsale/InvestmentAnalytics.sol';
import './security/ArgumentsChecker.sol';
import './STQToken.sol';
import 'zeppelin-solidity/contracts/ReentrancyGuard.sol';
import 'zeppelin-solidity/contracts/math/Math.sol';
import 'zeppelin-solidity/contracts/math/SafeMath.sol';


/// @title Storiqa ICO contract
contract STQCrowdsale is ArgumentsChecker, ReentrancyGuard, multiowned, InvestmentAnalytics {
    using Math for uint256;
    using SafeMath for uint256;
    using FixedTimeBonuses for FixedTimeBonuses.Data;

    enum IcoState { INIT, ICO, PAUSED, FAILED, DISTRIBUTING_BONUSES, SUCCEEDED }

    /// @dev bookkeeping for last investment bonus
    struct LastInvestment {
        address investor;
        uint payment;

        // time-based bonus which was already received by the investor
        uint timeBonus;
    }


    event StateChanged(IcoState _state);
    event FundTransfer(address backer, uint amount, bool isContribution);


    modifier requiresState(IcoState _state) {
        require(m_state == _state);
        _;
    }

    /// @dev triggers some state changes based on current time
    /// @param investor optional refund parameter
    /// @param payment optional refund parameter
    /// note: function body could be skipped!
    modifier timedStateChange(address investor, uint payment) {
        if (IcoState.INIT == m_state && getCurrentTime() >= getStartTime())
            changeState(IcoState.ICO);

        if (IcoState.ICO == m_state && getCurrentTime() >= getEndTime()) {
            finishICO();

            if (payment > 0)
                investor.transfer(payment);
            // note that execution of further (but not preceding!) modifiers and functions ends here
        } else {
            _;
        }
    }

    /// @dev automatic check for unaccounted withdrawals
    /// @param investor optional refund parameter
    /// @param payment optional refund parameter
    modifier fundsChecker(address investor, uint payment) {
        uint atTheBeginning = m_funds.balance;
        if (atTheBeginning < m_lastFundsAmount) {
            changeState(IcoState.PAUSED);
            if (payment > 0)
                investor.transfer(payment);     // we cant throw (have to save state), so refunding this way
            // note that execution of further (but not preceding!) modifiers and functions ends here
        } else {
            _;

            if (m_funds.balance < atTheBeginning) {
                changeState(IcoState.PAUSED);
            } else {
                m_lastFundsAmount = m_funds.balance;
            }
        }
    }


    // PUBLIC interface

    function STQCrowdsale(address[] _owners, address _token, address _funds, address _teamTokens)
        multiowned(_owners, 2)
        validAddress(_token)
        validAddress(_funds)
        validAddress(_teamTokens)
    {
        require(3 == _owners.length);

        m_token = STQToken(_token);
        m_funds = FundsRegistry(_funds);
        m_teamTokens = _teamTokens;

        m_bonuses.bonuses.push(FixedTimeBonuses.Bonus({endTime: c_startTime + (1 weeks), bonus: 30}));
        m_bonuses.bonuses.push(FixedTimeBonuses.Bonus({endTime: c_startTime + (2 weeks), bonus: 25}));
        m_bonuses.bonuses.push(FixedTimeBonuses.Bonus({endTime: c_startTime + (3 weeks), bonus: 20}));
        m_bonuses.bonuses.push(FixedTimeBonuses.Bonus({endTime: c_startTime + (4 weeks), bonus: 15}));
        m_bonuses.bonuses.push(FixedTimeBonuses.Bonus({endTime: c_startTime + (5 weeks), bonus: 10}));
        m_bonuses.bonuses.push(FixedTimeBonuses.Bonus({endTime: c_startTime + (8 weeks), bonus: 5}));
        m_bonuses.bonuses.push(FixedTimeBonuses.Bonus({endTime: 1514246400, bonus: 0}));
        m_bonuses.validate(true);

        deployer = msg.sender;
    }


    // PUBLIC interface: payments

    // fallback function as a shortcut
    function() payable {
        require(0 == msg.data.length);
        buy();  // only internal call here!
    }

    /// @notice ICO participation
    function buy() public payable {     // dont mark as external!
        iaOnInvested(msg.sender, msg.value, false);
    }

    function iaOnInvested(address investor, uint payment, bool usingPaymentChannel)
        internal
        nonReentrant
        timedStateChange(investor, payment)
        fundsChecker(investor, payment)
    {
        require(m_state == IcoState.ICO || m_state == IcoState.INIT && isOwner(investor) /* for final test */);

        require(payment >= c_MinInvestment);

        uint startingInvariant = this.balance.add(m_funds.balance);

        // checking for max cap
        uint fundsAllowed = getMaximumFunds().sub(getTotalInvested());
        assert(0 != fundsAllowed);  // in this case state must not be IcoState.ICO
        payment = fundsAllowed.min256(payment);
        uint256 change = msg.value.sub(payment);

        // issue tokens
        var (stq, timeBonus) = calcSTQAmount(payment, usingPaymentChannel ? c_paymentChannelBonusPercent : 0);
        m_token.mint(investor, stq);

        // record payment
        m_funds.invested.value(payment)(investor);
        FundTransfer(investor, payment, true);

        recordInvestment(investor, payment, timeBonus);

        // check if ICO must be closed early
        if (change > 0)
        {
            assert(getMaximumFunds() == getTotalInvested());
            finishICO();

            // send change
            investor.transfer(change);
            assert(startingInvariant == this.balance.add(m_funds.balance).add(change));
        }
        else
            assert(startingInvariant == this.balance.add(m_funds.balance));
    }


    // PUBLIC interface: owners: maintenance

    /// @notice pauses ICO
    function pause()
        external
        timedStateChange(address(0), 0)
        requiresState(IcoState.ICO)
        onlyowner
    {
        changeState(IcoState.PAUSED);
    }

    /// @notice resume paused ICO
    function unpause()
        external
        timedStateChange(address(0), 0)
        requiresState(IcoState.PAUSED)
        onlymanyowners(sha3(msg.data))
    {
        changeState(IcoState.ICO);
        checkTime();
    }

    /// @notice consider paused ICO as failed
    function fail()
        external
        timedStateChange(address(0), 0)
        requiresState(IcoState.PAUSED)
        onlymanyowners(sha3(msg.data))
    {
        changeState(IcoState.FAILED);
    }

    /// @notice In case we need to attach to existent token
    function setToken(address _token)
        external
        validAddress(_token)
        timedStateChange(address(0), 0)
        requiresState(IcoState.PAUSED)
        onlymanyowners(sha3(msg.data))
    {
        m_token = STQToken(_token);
    }

    /// @notice In case we need to attach to existent funds
    function setFundsRegistry(address _funds)
        external
        validAddress(_funds)
        timedStateChange(address(0), 0)
        requiresState(IcoState.PAUSED)
        onlymanyowners(sha3(msg.data))
    {
        m_funds = FundsRegistry(_funds);
    }

    /// @notice explicit trigger for timed state changes
    function checkTime()
        public
        timedStateChange(address(0), 0)
        onlyowner
    {
    }

    /// @notice computing and distributing post-ICO bonuses
    function distributeBonuses(uint investorsLimit)
        external
        timedStateChange(address(0), 0)
        requiresState(IcoState.DISTRIBUTING_BONUSES)
    {
        uint limitIndex = uint(m_lastInvestments.length).min256(m_nextUndestributedBonusIndex + investorsLimit);
        uint iterations = 0;
        uint startingGas = msg.gas;
        while (m_nextUndestributedBonusIndex < limitIndex) {
            if (c_lastInvestmentsBonus > m_lastInvestments[m_nextUndestributedBonusIndex].timeBonus) {
                uint bonus = c_lastInvestmentsBonus.sub(m_lastInvestments[m_nextUndestributedBonusIndex].timeBonus);
                uint bonusSTQ = m_lastInvestments[m_nextUndestributedBonusIndex].payment.mul(c_STQperETH).mul(bonus).div(100);

                m_token.mint(m_lastInvestments[m_nextUndestributedBonusIndex].investor, bonusSTQ);
            }
            m_nextUndestributedBonusIndex++;

            // preventing gas limit hit
            uint avgGasPerIteration = startingGas.sub(msg.gas).div(++iterations);
            if (msg.gas < avgGasPerIteration * 3)
                break;
        }

        if (m_nextUndestributedBonusIndex == m_lastInvestments.length)
            changeState(IcoState.SUCCEEDED);
    }


    function createMorePaymentChannels(uint limit) external returns (uint) {
        require(isOwner(msg.sender) || msg.sender == deployer);
        return createMorePaymentChannelsInternal(limit);
    }


    // INTERNAL functions

    function finishICO() private {
        if (getTotalInvested() < getMinFunds())
            changeState(IcoState.FAILED);
        else
            changeState(IcoState.DISTRIBUTING_BONUSES);
    }

    /// @dev performs only allowed state transitions
    function changeState(IcoState _newState) private {
        assert(m_state != _newState);

        if (IcoState.INIT == m_state) {        assert(IcoState.ICO == _newState); }
        else if (IcoState.ICO == m_state) {    assert(IcoState.PAUSED == _newState || IcoState.FAILED == _newState || IcoState.DISTRIBUTING_BONUSES == _newState); }
        else if (IcoState.PAUSED == m_state) { assert(IcoState.ICO == _newState || IcoState.FAILED == _newState); }
        else if (IcoState.DISTRIBUTING_BONUSES == m_state) { assert(IcoState.SUCCEEDED == _newState); }
        else assert(false);

        m_state = _newState;
        StateChanged(m_state);

        // this should be tightly linked
        if (IcoState.SUCCEEDED == m_state) {
            onSuccess();
        } else if (IcoState.FAILED == m_state) {
            onFailure();
        }
    }

    function onSuccess() private {
        // mint tokens for owners
        uint tokensForTeam = m_token.totalSupply().mul(40).div(60);
        m_token.mint(m_teamTokens, tokensForTeam);

        m_funds.changeState(FundsRegistry.State.SUCCEEDED);
        m_funds.detachController();

        m_token.disableMinting();
        m_token.startCirculation();
        m_token.detachController();
    }

    function onFailure() private {
        m_funds.changeState(FundsRegistry.State.REFUNDING);
        m_funds.detachController();
    }


    function getLargePaymentBonus(uint payment) private constant returns (uint) {
        if (payment > 5000 ether) return 20;
        if (payment > 3000 ether) return 15;
        if (payment > 1000 ether) return 10;
        if (payment > 800 ether) return 8;
        if (payment > 500 ether) return 5;
        if (payment > 200 ether) return 2;
        return 0;
    }

    /// @dev calculates amount of STQ to which payer of _wei is entitled
    function calcSTQAmount(uint _wei, uint extraBonus) private constant returns (uint stq, uint timeBonus) {
        timeBonus = m_bonuses.getBonus(getCurrentTime());
        uint bonus = extraBonus.add(timeBonus).add(getLargePaymentBonus(_wei));

        // apply bonus
        stq = _wei.mul(c_STQperETH).mul(bonus.add(100)).div(100);
    }

    /// @dev records investments in a circular buffer
    function recordInvestment(address investor, uint payment, uint timeBonus) private {
        uint writeTo;
        assert(m_lastInvestments.length <= getLastMaxInvestments());
        if (m_lastInvestments.length < getLastMaxInvestments()) {
            // buffer is still expanding
            writeTo = m_lastInvestments.length++;
        }
        else {
            // reusing buffer
            writeTo = m_nextFreeLastInvestmentIndex++;
            if (m_nextFreeLastInvestmentIndex == m_lastInvestments.length)
                m_nextFreeLastInvestmentIndex = 0;
        }

        assert(writeTo < m_lastInvestments.length);
        m_lastInvestments[writeTo] = LastInvestment(investor, payment, timeBonus);
    }


    /// @dev start time of the ICO, inclusive
    function getStartTime() private constant returns (uint) {
        return c_startTime;
    }

    /// @dev end time of the ICO, inclusive
    function getEndTime() private constant returns (uint) {
        return m_bonuses.getLastTime();
    }

    /// @dev to be overridden in tests
    function getCurrentTime() internal constant returns (uint) {
        return now;
    }

    /// @dev to be overridden in tests
    function getMinFunds() internal constant returns (uint) {
        return c_MinFunds;
    }

    /// @dev to be overridden in tests
    function getMaximumFunds() internal constant returns (uint) {
        return c_MaximumFunds;
    }

    /// @dev amount of investments during all crowdsales
    function getTotalInvested() internal constant returns (uint) {
        return m_funds.totalInvested().add(4281 ether /* FIXME update me */);
    }

    /// @dev to be overridden in tests
    function getLastMaxInvestments() internal constant returns (uint) {
        return c_maxLastInvestments;
    }


    // FIELDS

    /// @notice starting exchange rate of STQ
    uint public constant c_STQperETH = 100000;

    /// @notice minimum investment
    uint public constant c_MinInvestment = 10 finney;

    /// @notice minimum investments to consider ICO as a success
    uint public constant c_MinFunds = 30000 ether;

    /// @notice maximum investments to be accepted during ICO
    uint public constant c_MaximumFunds = 90000 ether;

    /// @notice start time of the ICO
    uint public constant c_startTime = 1508889600;

    /// @notice authorised payment bonus
    uint public constant c_paymentChannelBonusPercent = 2;

    /// @notice timed bonuses
    FixedTimeBonuses.Data m_bonuses;

    uint public constant c_maxLastInvestments = 100;

    uint public constant c_lastInvestmentsBonus = 30;

    /// @dev bookkeeping for last investment bonus
    LastInvestment[] public m_lastInvestments;

    uint m_nextFreeLastInvestmentIndex;

    uint m_nextUndestributedBonusIndex;


    /// @dev state of the ICO
    IcoState public m_state = IcoState.INIT;

    /// @dev contract responsible for token accounting
    STQToken public m_token;

    address public m_teamTokens;

    address public deployer;

    /// @dev contract responsible for investments accounting
    FundsRegistry public m_funds;

    /// @dev last recorded funds
    uint256 public m_lastFundsAmount;
}
