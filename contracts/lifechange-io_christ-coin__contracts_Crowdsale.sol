pragma solidity ^0.4.11;

import "./Zeppelin/SafeMath.sol";
import "./Zeppelin/Pausable.sol";
import "./Controller.sol";
import "./Shared.sol";

/** @title Crowdsale for the Christ Coin Token */
contract Crowdsale is Shared, Pausable {
  using SafeMath for uint;

  uint public constant START = 1506945600;                  // October 2, 2017 7:00:00 AM CST
  uint public constant END = 1512133200;                    // December 1, 2017 7:00:00 AM CST
  uint public constant CAP = 450 * (10 ** (6 + DECIMALS));  // 450 million tokens
  
  uint public weiRaised;                                    // Total wei amount raised
  uint public tokensDistributed;                            // Total tokens distributed less bonus tokens
  uint public bonusTokensDistributed;                       // Total bonus tokens distributed
  uint public presaleTokensDistributed;                     // Presale tokens distributed (for informational purposes)
  uint public presaleBonusTokensDistributed;                // Presale bonus tokens distributed (for informational purposes)
  bool public crowdsaleFinalized;                           // Flag for if the crowdsale has been finalized or not
  bool public presaleFinalized;                             // Ensures the presale is only funded once

  Controller public controller;
  Round[] public rounds;
  Round public currentRound;

  struct Presale {
    address purchaser;
    uint weiAmount;
  }

  struct Round {
    uint index;
    uint endAmount;
    uint rate;
    uint incentiveDivisor; // Bonuses are expressed as (100 / incentiveDivisor)
  }

  struct Purchase {
    uint tokens;
    uint bonus;
  }

  event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint value, uint amount);

  function Crowdsale() {
    require(END >= START);

    rounds.push(Round(0, 75 * (10 ** (6 + DECIMALS)), 35460992907801, 4));    // Up to 75 million tokens, 25% bonus
    rounds.push(Round(1, 150 * (10 ** (6 + DECIMALS)), 106382978723404, 10)); // Up to 150 million tokens, 10% bonus
    rounds.push(Round(2, 250 * (10 ** (6 + DECIMALS)), 212765957446808, 0));  // Up to 250 million tokens, 0% bonus
    rounds.push(Round(3, 450 * (10 ** (6 + DECIMALS)), 319148936170213, 0));  // Up to 450 million tokens, 0% bonus
    currentRound = rounds[0];
  }

  function setController(address _address) onlyOwner {
    controller = Controller(_address);
  }

  function () payable whenNotPaused {
    buyTokens(msg.sender);
  }

  // Method separated to allow for gifting of tokens
  function buyTokens(address _beneficiary) payable whenNotPaused {
    require(_beneficiary != 0x0);
    require(validPurchase());

    processPurchase(msg.sender, _beneficiary, msg.value);
    LIFE_CHANGE_WALLET.transfer(msg.value);  
  }

  // Gets purchase amount, increments counters, transfers tokens, and calls TokenPurchase event
  function processPurchase(address _from, address _beneficiary, uint _weiAmount) internal returns (Purchase purchase) {
    purchase = getPurchase(_weiAmount, tokensDistributed);

    require(tokensDistributed.add(purchase.tokens) <= CAP);

    uint _tokensWithBonus = purchase.tokens.add(purchase.bonus);
    bonusTokensDistributed = bonusTokensDistributed.add(purchase.bonus);
    tokensDistributed = tokensDistributed.add(purchase.tokens);

    weiRaised = weiRaised.add(_weiAmount);

    controller.transferWithEvent(CROWDSALE_WALLET, _beneficiary, _tokensWithBonus);
    TokenPurchase(_from, _beneficiary, _weiAmount, _tokensWithBonus);
  }

  // Determines amount of tokens and bonus tokens to distribute to beneficiary
  // Takes purchases that cross round boundaries in to account via recursive calls
  // Takes remaining wei amount to process and how many tokens have been distributed thus far as parameters
  function getPurchase(uint _weiAmount, uint _tokensDistributed) internal returns (Purchase purchase) {
    uint _roundTokensRemaining = currentRound.endAmount.sub(_tokensDistributed);
    uint _roundWeiRemaining = _roundTokensRemaining.mul(currentRound.rate).div(10 ** DECIMALS);
    uint _tokens = _weiAmount.div(currentRound.rate).mul(10 ** DECIMALS);
    uint _incentiveDivisor = currentRound.incentiveDivisor;
    
    // Does requested token amount stay within round boundary?
    if (_tokens <= _roundTokensRemaining) {
      purchase.tokens = _tokens;

      if (_incentiveDivisor > 0) {
        purchase.bonus = _tokens.div(_incentiveDivisor);
      }
    } else {
      // Increment round if boundary reached
      currentRound = rounds[currentRound.index + 1];

      uint _roundBonus = 0;
      if (_incentiveDivisor > 0) {
        _roundBonus = _roundTokensRemaining.div(_incentiveDivisor);
      }
      
      // Recursive call for next round
      purchase = getPurchase(_weiAmount.sub(_roundWeiRemaining), _tokensDistributed.add(_roundTokensRemaining));
      purchase.tokens = purchase.tokens.add(_roundTokensRemaining);
      purchase.bonus = purchase.bonus.add(_roundBonus);
    }
  }

  function validPurchase() internal constant returns (bool) {
    bool notAtCap = tokensDistributed < CAP;
    bool nonZeroPurchase = msg.value != 0;
    bool withinPeriod = now >= START && now <= END;

    return notAtCap && nonZeroPurchase && withinPeriod && presaleFinalized;
  }

  // Determines if the crowdsale is over
  function hasEnded() constant returns (bool) {
    return crowdsaleFinalized || tokensDistributed == CAP || now > END;
  }

  // Allows the owner to add a presale
  function addPresale(address _beneficiary, uint _weiAmount) onlyOwner returns (bool) {
    require(!presaleFinalized);
    require(_beneficiary != 0x0);
    require(_weiAmount != 0);
    
    Purchase memory purchase = processPurchase(0x0, _beneficiary, _weiAmount);
    presaleTokensDistributed = presaleTokensDistributed.add(purchase.tokens);
    presaleBonusTokensDistributed = presaleBonusTokensDistributed.add(purchase.bonus);
 
    return true;
  }

  // Do not allow any more presales, advance current round to round 1
  function finalizePresale() onlyOwner {
    require(!presaleFinalized);

    // Crowdsale starts in first round
    currentRound = rounds[1];
    presaleFinalized = true;
  }

  // Owner can only finalize crowdsale once the cap is met or time expires
  // There is a 25% bonus to token holders if sold out
  // Remainder of tokens are vested over 7 years
  function finalizeCrowdsale() onlyOwner {
    require(!crowdsaleFinalized);
    require(hasEnded());
    
    uint _toVest = controller.balanceOf(CROWDSALE_WALLET);
    if (tokensDistributed == CAP) {
      _toVest = _toVest.sub(CAP.div(4));
    }

    controller.transferWithEvent(CROWDSALE_WALLET, LIFE_CHANGE_VESTING_WALLET, _toVest);
    controller.startVesting(_toVest, 7 years);

    crowdsaleFinalized = true;
  }
}