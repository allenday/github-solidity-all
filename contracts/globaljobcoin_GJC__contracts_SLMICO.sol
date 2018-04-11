pragma solidity ^0.4.15;

import './SLMToken.sol';
import './math/SafeMath.sol';
import './lifecycle/Pausable.sol';
import './TokenVesting.sol';

/**
 * @title SLMICO
 * @dev SLMICO is a base contract for managing a token crowdsale.
 * SLMICO have a start and end timestamps, where investors can make
 * token purchases and the crowdsale will assign them tokens based
 * on a token per ETH rate. Funds collected are forwarded to a wallet
 * as they arrive.
 */
contract SLMICO is Pausable{
  using SafeMath for uint256;

  //Gas/GWei
  uint constant public minContribAmount = 0.01 ether;

  // The token being sold
  SLMToken public token;
  uint256 constant public tokenDecimals = 18;

  // The vesting contract
  TokenVesting public vesting;
  uint256 constant public VESTING_TIMES = 4;
  uint256 constant public DURATION_PER_VESTING = 52 weeks;

  // start and end timestamps where investments are allowed (both inclusive)
  uint256 public startTime;
  uint256 public endTime;

  // need to be enabled to allow investor to participate in the ico
  bool public icoEnabled;

  // address where funds are collected
  address public multisignWallet;

  // amount of raised money in wei
  uint256 public weiRaised;

  // totalSupply
  uint256 constant public totalSupply = 100000000 * (10 ** tokenDecimals);
  //pre sale cap
  uint256 constant public preSaleCap = 10000000 * (10 ** tokenDecimals);
  //sale cap
  uint256 constant public initialICOCap = 60000000 * (10 ** tokenDecimals);
  //founder share
  uint256 constant public tokensForFounder = 10000000 * (10 ** tokenDecimals);
  //dev team share
  uint256 constant public tokensForDevteam = 10000000 * (10 ** tokenDecimals);
  //Partners share
  uint256 constant public tokensForPartners = 5000000 * (10 ** tokenDecimals);
  //Charity share
  uint256 constant public tokensForCharity = 3000000 * (10 ** tokenDecimals);
  //Bounty share
  uint256 constant public tokensForBounty = 2000000 * (10 ** tokenDecimals);
    
  //Sold presale tokens
  uint256 public soldPreSaleTokens; 
  uint256 public sentPreSaleTokens;

  //ICO tokens
  //Is calcluated as: initialICOCap + preSaleCap - soldPreSaleTokens
  uint256 public icoCap; 
  uint256 public icoSoldTokens; 
  bool public icoEnded = false;

  //Sale rates
  uint256 constant public RATE_FOR_WEEK1 = 525;
  uint256 constant public RATE_FOR_WEEK2 = 455;
  uint256 constant public RATE_FOR_WEEK3 = 420;
  uint256 constant public RATE_NO_DISCOUNT = 350;


  /**
   * event for token purchase logging
   * @param purchaser who paid for the tokens
   * @param beneficiary who got the tokens
   * @param value weis paid for purchase
   * @param amount amount of tokens purchased
   */ 
  event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);


  function SLMICO(address _multisignWallet) {
    require(_multisignWallet != address(0));
    token = createTokenContract();
    //send all dao tokens to multiwallet
    uint256 tokensToDao = tokensForDevteam.add(tokensForPartners).add(tokensForBounty).add(tokensForCharity);
    multisignWallet = _multisignWallet;
    token.transfer(multisignWallet, tokensToDao);
  }

  function createVestingForFounder(address founderAddress) external onlyOwner(){
    require(founderAddress != address(0));
    //create only once
    require(address(vesting) == address(0));
    vesting = createTokenVestingContract(address(token));
    // create vesting schema for founders from now, total token amount is divided in 4 periods of 12 months each
    vesting.createVestingByDurationAndSplits(founderAddress, tokensForFounder, now, DURATION_PER_VESTING, VESTING_TIMES);
    //send tokens to vesting contracts
    token.transfer(address(vesting), tokensForFounder);
  }

  //
  // Token related operations
  //

  // creates the token to be sold. 
  // override this method to have crowdsale of a specific mintable token.
  function createTokenContract() internal returns (SLMToken) {
    return new SLMToken();
  }

  // creates the token to be sold.
  // override this method to have crowdsale of a specific mintable token.
  function createTokenVestingContract(address tokenAddress) internal returns (TokenVesting) {
    require(address(token) != address(0));
    return new TokenVesting(tokenAddress);
  }


  // enable token tranferability
  function enableTokenTransferability() external onlyOwner {
    require(token != address(0));
    token.unpause(); 
  }

  // disable token tranferability
  function disableTokenTransferability() external onlyOwner {
    require(token != address(0));
    token.pause(); 
  }


  //
  // Presale related operations
  //

  // set total pre sale sold token
  // can not be changed once the ico is enabled
  // Ico cap is determined by SaleCap + PreSaleCap - soldPreSaleTokens 
  function setSoldPreSaleTokens(uint256 _soldPreSaleTokens) external onlyOwner{
    require(!icoEnabled);
    require(_soldPreSaleTokens <= preSaleCap);
    soldPreSaleTokens = _soldPreSaleTokens;
  }

  // transfer pre sale tokend to investors
  // soldPreSaleTokens need to be set beforehand, and bigger than 0
  // the total amount to tranfered need to be less or equal to soldPreSaleTokens 
  function transferPreSaleTokens(uint256 tokens, address beneficiary) external onlyOwner {
    require(beneficiary != address(0));
    require(soldPreSaleTokens > 0);
    uint256 newSentPreSaleTokens = sentPreSaleTokens.add(tokens);
    require(newSentPreSaleTokens <= soldPreSaleTokens);
    sentPreSaleTokens = newSentPreSaleTokens;
    token.transfer(beneficiary, tokens);
  }


  //
  // ICO related operations
  //

  // set multisign wallet
  function setMultisignWallet(address _multisignWallet) external onlyOwner{
    // need to be set before the ico start
    require(!icoEnabled || now < startTime);
    require(_multisignWallet != address(0));
    multisignWallet = _multisignWallet;
  }

  // delegate vesting contract owner
  function delegateVestingContractOwner(address newOwner) external onlyOwner{
    vesting.transferOwnership(newOwner);
  }

  // set contribution dates
  function setContributionDates(uint256 _startTime, uint256 _endTime) external onlyOwner{
    require(!icoEnabled);
    require(_startTime >= now);
    require(_endTime >= _startTime);
    startTime = _startTime;
    endTime = _endTime;
  }

  // enable ICO, need to be true to actually start ico
  // multisign wallet need to be set, because once ico started, invested funds is transfered to this address
  // once ico is enabled, following parameters can not be changed anymore:
  // startTime, endTime, soldPreSaleTokens
  function enableICO() external onlyOwner{
    require(startTime >= now);

    require(multisignWallet != address(0));
    icoEnabled = true;
    icoCap = initialICOCap.add(preSaleCap).sub(soldPreSaleTokens);
  }


  // fallback function can be used to buy tokens
  function () payable whenNotPaused {
    buyTokens(msg.sender);
  }

  // low level token purchase function
  function buyTokens(address beneficiary) public payable whenNotPaused {
    require(beneficiary != address(0));
    require(validPurchase());

    uint256 weiAmount = msg.value;
    uint256 returnWeiAmount;

    // calculate token amount to be created
    uint rate = getRate();
    assert(rate > 0);
    uint256 tokens = weiAmount.mul(rate);

    uint256 newIcoSoldTokens = icoSoldTokens.add(tokens);

    if (newIcoSoldTokens > icoCap) {
        newIcoSoldTokens = icoCap;
        tokens = icoCap.sub(icoSoldTokens);
        uint256 newWeiAmount = tokens.div(rate);
        returnWeiAmount = weiAmount.sub(newWeiAmount);
        weiAmount = newWeiAmount;
    }

    // update state
    weiRaised = weiRaised.add(weiAmount);

    token.transfer(beneficiary, tokens);
    icoSoldTokens = newIcoSoldTokens;
    if (returnWeiAmount > 0){
        msg.sender.transfer(returnWeiAmount);
    }

    TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);

    forwardFunds();
  }

  // send ether to the fund collection wallet
  // override to create custom fund forwarding mechanisms
  function forwardFunds() internal {
    multisignWallet.transfer(this.balance);
  }

  // unsold ico tokens transfer automatically in endIco
  //function transferUnsoldIcoTokens() onlyOwner {
  //  require(hasEnded());
  //  require(icoSoldTokens < icoCap);
  //  uint256 unsoldTokens = icoCap.sub(icoSoldTokens);
  //  token.transfer(multisignWallet, unsoldTokens);
  //}

  // @return true if the transaction can buy tokens
  function validPurchase() internal constant returns (bool) {
    bool withinPeriod = now >= startTime && now <= endTime;
    bool nonMinimumPurchase = msg.value >= minContribAmount;
    bool icoTokensAvailable = icoSoldTokens < icoCap;
    return !icoEnded && icoEnabled && withinPeriod && nonMinimumPurchase && icoTokensAvailable;
  }

  // end ico by owner, not really needed in normal situation
  function endIco() external onlyOwner {
    require(!icoEnded);
    icoEnded = true;
    // send unsold tokens to multi-sign wallet
    uint256 unsoldTokens = icoCap.sub(icoSoldTokens);
    token.transfer(multisignWallet, unsoldTokens);
  }

  // @return true if crowdsale event has ended
  function hasEnded() public constant returns (bool) {
    return (icoEnded || icoSoldTokens >= icoCap || now > endTime);
  }


  function getRate() public constant returns(uint){
    require(now >= startTime);
    if (now < startTime.add(1 weeks)){
      // week 1
      return RATE_FOR_WEEK1;
    }else if (now < startTime.add(2 weeks)){
      // week 2
      return RATE_FOR_WEEK2;
    }else if (now < startTime.add(3 weeks)){
      // week 3
      return RATE_FOR_WEEK3;
    }else if (now < endTime){
      // no discount
      return RATE_NO_DISCOUNT;
    }
    return 0;
  }

  // drain all eth for owner in an emergency situation
  function drain() external onlyOwner {
    owner.transfer(this.balance);
  }
}
