pragma solidity 0.4.15;

import '../ownership/MultiownedControlled.sol';
import 'zeppelin-solidity/contracts/token/StandardToken.sol';


/// @title StandardToken which can be minted by another contract.
contract MintableMultiownedToken is MultiownedControlled, StandardToken {

    /// @dev parameters of an extra token emission
    struct EmissionInfo {
        // tokens created
        uint256 created;

        // totalSupply at the moment of emission (excluding created tokens)
        uint256 totalSupplyWas;
    }

    event Mint(address indexed to, uint256 amount);
    event Emission(uint256 tokensCreated, uint256 totalSupplyWas, uint256 time);
    event Dividend(address indexed to, uint256 amount);


    // PUBLIC interface

    function MintableMultiownedToken(address[] _owners, uint _signaturesRequired, address _minter)
        MultiownedControlled(_owners, _signaturesRequired, _minter)
    {
        dividendsPool = this;   // or any other special unforgeable value, actually

        // emission #0 is a dummy: because of default value 0 in m_lastAccountEmission
        m_emissions.push(EmissionInfo({created: 0, totalSupplyWas: 0}));
    }

    /// @notice Request dividends for current account.
    function requestDividends() external {
        payDividendsTo(msg.sender);
    }

    /// @notice hook on standard ERC20#transfer to pay dividends
    function transfer(address _to, uint256 _value) returns (bool) {
        payDividendsTo(msg.sender);
        payDividendsTo(_to);
        return super.transfer(_to, _value);
    }

    /// @notice hook on standard ERC20#transferFrom to pay dividends
    function transferFrom(address _from, address _to, uint256 _value) returns (bool) {
        payDividendsTo(_from);
        payDividendsTo(_to);
        return super.transferFrom(_from, _to, _value);
    }

    // Disabled: this could be undesirable because sum of (balanceOf() for each token owner) != totalSupply
    // (but: sum of (balances[owner] for each token owner) == totalSupply!).
    //
    // @notice hook on standard ERC20#balanceOf to take dividends into consideration
    // function balanceOf(address _owner) constant returns (uint256) {
    //     var (hasNewDividends, dividends) = calculateDividendsFor(_owner);
    //     return hasNewDividends ? super.balanceOf(_owner).add(dividends) : super.balanceOf(_owner);
    // }


    /// @dev mints new tokens
    function mint(address _to, uint256 _amount) external onlyController {
        require(m_externalMintingEnabled);
        payDividendsTo(_to);
        mintInternal(_to, _amount);
    }

    /// @dev disables mint(), irreversible!
    function disableMinting() external onlyController {
        require(m_externalMintingEnabled);
        m_externalMintingEnabled = false;
    }


    // INTERNAL functions

    /**
     * @notice Starts new token emission
     * @param _tokensCreated Amount of tokens to create
     * @dev Dividends are not distributed immediately as it could require billions of gas,
     * instead they are `pulled` by a holder from dividends pool account before any update to the holder account occurs.
     */
    function emissionInternal(uint256 _tokensCreated) internal {
        require(0 != _tokensCreated);
        require(_tokensCreated < totalSupply / 2);  // otherwise it looks like an error

        uint256 totalSupplyWas = totalSupply;

        m_emissions.push(EmissionInfo({created: _tokensCreated, totalSupplyWas: totalSupplyWas}));
        mintInternal(dividendsPool, _tokensCreated);

        Emission(_tokensCreated, totalSupplyWas, now);
    }

    function mintInternal(address _to, uint256 _amount) internal {
        totalSupply = totalSupply.add(_amount);
        balances[_to] = balances[_to].add(_amount);
        Transfer(this, _to, _amount);
        Mint(_to, _amount);
    }

    /// @dev adds dividends to the account _to
    function payDividendsTo(address _to) internal {
        var (hasNewDividends, dividends) = calculateDividendsFor(_to);
        if (!hasNewDividends)
            return;

        if (0 != dividends) {
            balances[dividendsPool] = balances[dividendsPool].sub(dividends);
            balances[_to] = balances[_to].add(dividends);
            Transfer(dividendsPool, _to, dividends);
        }
        m_lastAccountEmission[_to] = getLastEmissionNum();
    }

    /// @dev calculates dividends for the account _for
    /// @return (true if state has to be updated, dividend amount (could be 0!))
    function calculateDividendsFor(address _for) constant internal returns (bool hasNewDividends, uint dividends) {
        assert(_for != dividendsPool);  // no dividends for the pool!

        uint256 lastEmissionNum = getLastEmissionNum();
        uint256 lastAccountEmissionNum = m_lastAccountEmission[_for];
        assert(lastAccountEmissionNum <= lastEmissionNum);
        if (lastAccountEmissionNum == lastEmissionNum)
            return (false, 0);

        uint256 initialBalance = balances[_for];    // beware of recursion!
        if (0 == initialBalance)
            return (true, 0);

        uint256 balance = initialBalance;
        for (uint256 emissionToProcess = lastAccountEmissionNum + 1; emissionToProcess <= lastEmissionNum; emissionToProcess++) {
            EmissionInfo storage emission = m_emissions[emissionToProcess];
            assert(0 != emission.created && 0 != emission.totalSupplyWas);

            uint256 dividend = balance.mul(emission.created).div(emission.totalSupplyWas);
            Dividend(_for, dividend);

            balance = balance.add(dividend);
        }

        return (true, balance.sub(initialBalance));
    }

    function getLastEmissionNum() private constant returns (uint256) {
        return m_emissions.length - 1;
    }


    // FIELDS

    /// @notice if this true then token is still externally mintable (but this flag does't affect emissions!)
    bool public m_externalMintingEnabled = true;

    /// @dev internal address of dividends in balances mapping.
    address dividendsPool;

    /// @notice record of issued dividend emissions
    EmissionInfo[] public m_emissions;

    /// @dev for each token holder: last emission (index in m_emissions) which was processed for this holder
    mapping(address => uint256) m_lastAccountEmission;
}
