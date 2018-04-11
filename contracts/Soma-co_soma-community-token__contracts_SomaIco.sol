pragma solidity ^0.4.15;

import 'zeppelin-solidity/contracts/token/ERC20Basic.sol';
import 'zeppelin-solidity/contracts/token/PausableToken.sol';


contract SomaIco is PausableToken {
    using SafeMath for uint256;

    string public name = "Soma Community Token";
    string public symbol = "SCT";
    uint8 public decimals = 18;

    address public liquidityReserveWallet; // address where liquidity reserve tokens will be delivered
    address public wallet; // address where funds are collected
    address public marketingWallet; // address which controls marketing token pool

    uint256 public icoStartTimestamp; // ICO start timestamp
    uint256 public icoEndTimestamp; // ICO end timestamp

    uint256 public totalRaised = 0; // total amount of money raised in wei
    uint256 public totalSupply; // total token supply with decimals precisoin
    uint256 public marketingPool; // marketing pool with decimals precisoin
    uint256 public tokensSold = 0; // total number of tokens sold

    bool public halted = false; //the owner address can set this to true to halt the crowdsale due to emergency

    uint256 public icoEtherMinCap; // should be specified as: 8000 * 1 ether
    uint256 public icoEtherMaxCap; // should be specified as: 120000 * 1 ether
    uint256 public rate = 450; // standard SCT/ETH rate

    event Burn(address indexed burner, uint256 value);

    function SomaIco(
        address newWallet,
        address newMarketingWallet,
        address newLiquidityReserveWallet,
        uint256 newIcoEtherMinCap,
        uint256 newIcoEtherMaxCap,
        uint256 totalPresaleRaised
    ) {
        require(newWallet != 0x0);
        require(newMarketingWallet != 0x0);
        require(newLiquidityReserveWallet != 0x0);
        require(newIcoEtherMinCap <= newIcoEtherMaxCap);
        require(newIcoEtherMinCap > 0);
        require(newIcoEtherMaxCap > 0);

        pause();

        icoEtherMinCap = newIcoEtherMinCap;
        icoEtherMaxCap = newIcoEtherMaxCap;
        wallet = newWallet;
        marketingWallet = newMarketingWallet;
        liquidityReserveWallet = newLiquidityReserveWallet;

        // calculate marketingPool and totalSupply based on the max cap:
        // totalSupply = rate * icoEtherMaxCap + marketingPool
        // marketingPool = 10% * totalSupply
        // hence:
        // totalSupply = 10/9 * rate * icoEtherMaxCap
        totalSupply = icoEtherMaxCap.mul(rate).mul(10).div(9);
        marketingPool = totalSupply.div(10);

        // account for the funds raised during the presale
        totalRaised = totalRaised.add(totalPresaleRaised);

        // assign marketing pool to marketing wallet
        assignTokens(marketingWallet, marketingPool);
    }

    /// fallback function to buy tokens
    function () nonHalted nonZeroPurchase acceptsFunds payable {
        address recipient = msg.sender;
        uint256 weiAmount = msg.value;

        uint256 amount = weiAmount.mul(rate);

        assignTokens(recipient, amount);
        totalRaised = totalRaised.add(weiAmount);

        forwardFundsToWallet();
    }

    modifier acceptsFunds() {
        bool hasStarted = icoStartTimestamp != 0 && now >= icoStartTimestamp;
        require(hasStarted);

        // ICO is continued over the end date until the min cap is reached
        bool isIcoInProgress = now <= icoEndTimestamp
                || (icoEndTimestamp == 0) // before dates are set
                || totalRaised < icoEtherMinCap;
        require(isIcoInProgress);

        bool isBelowMaxCap = totalRaised < icoEtherMaxCap;
        require(isBelowMaxCap);

        _;
    }

    modifier nonHalted() {
        require(!halted);
        _;
    }

    modifier nonZeroPurchase() {
        require(msg.value > 0);
        _;
    }

    function forwardFundsToWallet() internal {
        wallet.transfer(msg.value); // immediately send Ether to wallet address, propagates exception if execution fails
    }

    function assignTokens(address recipient, uint256 amount) internal {
        balances[recipient] = balances[recipient].add(amount);
        tokensSold = tokensSold.add(amount);

        // sanity safeguard
        if (tokensSold > totalSupply) {
            // there is a chance that tokens are sold over the supply:
            // a) when: total presale bonuses > (maxCap - totalRaised) * rate
            // b) when: last payment goes over the maxCap
            totalSupply = tokensSold;
        }

        Transfer(0x0, recipient, amount);
    }

    function setIcoDates(uint256 newIcoStartTimestamp, uint256 newIcoEndTimestamp) public onlyOwner {
        require(newIcoStartTimestamp < newIcoEndTimestamp);
        require(!isIcoFinished());
        icoStartTimestamp = newIcoStartTimestamp;
        icoEndTimestamp = newIcoEndTimestamp;
    }

    function setRate(uint256 _rate) public onlyOwner {
        require(!isIcoFinished());
        rate = _rate;
    }

    function haltFundraising() public onlyOwner {
        halted = true;
    }

    function unhaltFundraising() public onlyOwner {
        halted = false;
    }

    function isIcoFinished() public constant returns (bool icoFinished) {
        return (totalRaised >= icoEtherMinCap && icoEndTimestamp != 0 && now > icoEndTimestamp) ||
               (totalRaised >= icoEtherMaxCap);
    }

    function prepareLiquidityReserve() public onlyOwner {
        require(isIcoFinished());
        
        uint256 unsoldTokens = totalSupply.sub(tokensSold);
        // make sure there are any unsold tokens to be assigned
        require(unsoldTokens > 0);

        // try to allocate up to 10% of total sold tokens to Liquidity Reserve fund:
        uint256 liquidityReserveTokens = tokensSold.div(10);
        if (liquidityReserveTokens > unsoldTokens) {
            liquidityReserveTokens = unsoldTokens;
        }
        assignTokens(liquidityReserveWallet, liquidityReserveTokens);
        unsoldTokens = unsoldTokens.sub(liquidityReserveTokens);

        // if there are still unsold tokens:
        if (unsoldTokens > 0) {
            // decrease  (burn) total supply by the number of unsold tokens:
            totalSupply = totalSupply.sub(unsoldTokens);
        }

        // make sure there are no tokens left
        assert(tokensSold == totalSupply);
    }

    function manuallyAssignTokens(address recipient, uint256 amount) public onlyOwner {
        require(tokensSold < totalSupply);
        assignTokens(recipient, amount);
    }

    /**
     * @dev Burns a specific amount of tokens.
     * @param _value The amount of token to be burned.
     */
    function burn(uint256 _value) public whenNotPaused {
        require(_value > 0);

        address burner = msg.sender;
        balances[burner] = balances[burner].sub(_value);
        totalSupply = totalSupply.sub(_value);
        Burn(burner, _value);
    }

}
