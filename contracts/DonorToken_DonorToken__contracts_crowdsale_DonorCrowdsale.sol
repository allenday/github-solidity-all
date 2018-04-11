pragma solidity ^0.4.13;

import "zeppelin-solidity/contracts/crowdsale/Crowdsale.sol";
import "zeppelin-solidity/contracts/crowdsale/CappedCrowdsale.sol";
import "../ownership/Benable.sol";
import "../ownership/Devable.sol";
import "../base/ERC23Contract.sol";
import "../base/ERC677Contract.sol";
import "../token/DonorToken.sol";

/**
 * @title DonorCrowdsale
 * @dev Extension of Crowdsale for donations
 */
contract DonorCrowdsale is Crowdsale, CappedCrowdsale, Benable, Devable, ERC23Contract, ERC677Contract {
  using SafeMath for uint256;

  uint256 public constant UINT256_MAX = 2**256 - 1;

  // feel free to overridde!
  uint256 public constant CAP_DEFAULT = 100000 ether; // Crowdsale will end when this much ether is received
  uint256 public constant TOKEN_RATE = 1 wei; // NOTE: instead of mul, we use div; i.e. this is ether cost per token, aka minimum payment
  uint256 public constant DONEE_PCT = 95; // donee gets this, dev fund gets remainder
  uint256 public constant DONEE_TOKEN_THRESHOLD = 1 ether; // every time we reach this threshold raised, also mint 1 token to donee, dev
  uint256 public constant DONEE_SEND_THRESHOLD = 1 ether; // "payout" ether to donee each time we have this much
  uint256 public constant EARLYBIRD_PERIOD = 4 weeks; // anyone who buys in this period receives a bonus
  uint256 public constant BONUS_THRESHOLD = 1 ether; // for each of these donated, give bonus
  uint256 public constant BONUS_TOKEN_RATE = 100 finney; // bonus rate awarded (proportional to rate!)
  bool public constant REFUND_FAIL_THROW = false; // if refund attempt fails, throw?

  /**
   * event for token purchase logging
   * @param purchaser who paid for the tokens
   * @param beneficiary who got the tokens
   * @param value weis paid for purchase
   * @param amount amount of tokens purchased
   * @param refund weis refunded
   */ 
  event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount, uint256 refund);


  function DonorCrowdsale(uint256 _startTime, uint256 _endTime, uint256 _rate, address _wallet, uint256 _cap)
    Crowdsale(_startTime, _endTime, _rate, _wallet)
    CappedCrowdsale(_cap) 
  {
    ben = _wallet;
    transferOwnership(this); // give the contract to itself
  }

  // override this method to have crowdsale of a specific DonorToken.
  function createTokenContract() internal returns (MintableToken) {
    return new DonorToken();
  }

  // low level token purchase function
  function buyTokens(address beneficiary) public payable {
    require(beneficiary != 0x0);
    require(validPurchase());

    uint256 weiAmount = msg.value;

    // calculate token amount to be created
    uint256 tokens = weiAmount.div(rate); // NOTE: using div instead of mul!
    require(tokens > 0); // if payment wasn't enough for 1 token, throw

    uint256 weiAccept = tokens.mul(rate);
    uint256 weiRefund = weiAmount.sub(weiAccept);

    // special processing
    uint256 tokensBonus = buyTokensBonus(tokens, weiAccept);
    tokens = tokens.add(tokensBonus);

    // update state
    weiRaised = weiRaised.add(weiAccept);

    token.mint(beneficiary, tokens);
    TokenPurchase(msg.sender, beneficiary, weiAccept, tokens, weiRefund);

    if (weiRefund > 0) {
      if (REFUND_FAIL_THROW) {
        // throws on fail
        msg.sender.transfer(weiRefund);
      } else {
        // does not throw (dust kept for donation)
        if (!msg.sender.send(weiRefund)) {
          return; // out of gas, apparently
        }
      }
    }

    forwardFunds();
  }

  // any "non-critical" special processing (bonus tokens, etc) at buy time
  // override to create custom bonus mechanisms (can also just return 0)
  function buyTokensBonus(uint256 tokens, uint256 weiAccept) internal returns (uint256) {
    uint256 tokensBonus = 0;

    checkThreshold(weiAccept);
    tokensBonus = tokensBonus.add(checkEarlybird(tokens));
    tokensBonus = tokensBonus.add(checkWhale(weiAccept));

    return tokensBonus;
  }

  // also mint 1 token to donee, dev per threshold diff (ex: per ether received)
  function checkThreshold(uint256 weiAccept) internal returns (bool) {
    uint256 weiRaisedPrev = weiRaised;
    uint256 weiRaisedNext = weiRaisedPrev.add(weiAccept);
    uint256 weiThreshPrev = weiRaisedPrev.div(DONEE_TOKEN_THRESHOLD);
    uint256 weiThreshNext = weiRaisedNext.div(DONEE_TOKEN_THRESHOLD);
    uint256 weiThreshDiff = weiThreshNext.sub(weiThreshPrev);
    if (weiThreshDiff > 0) {
      token.mint(wallet, weiThreshDiff);
      token.mint(dev, weiThreshDiff);
      return true;
    }

    return false;
  }

  // bonus X% where X is days left in earlybird period
  function checkEarlybird(uint256 tokens) internal constant returns (uint256) {
    uint256 startTimeSince = now.sub(startTime);
    if (startTimeSince < EARLYBIRD_PERIOD) {
      uint256 daysRem = EARLYBIRD_PERIOD.sub(startTimeSince).div(1 days);
      return tokens.mul(daysRem).div(100);
    }

    return 0;
  }

  // bonus X finney's worth for every ether donated
  function checkWhale(uint256 weiAccept) internal constant returns (uint256) {
    return weiAccept.div(BONUS_THRESHOLD).mul(BONUS_TOKEN_RATE).div(rate);
  }

  // send proceeds to the donee wallet, and any leftovers to dev
  function forwardFunds() internal {
    uint256 bal = this.balance;
    // require(bal > 0); // don't need this due to DONEE_SEND_THRESHOLD check below

    if (bal < DONEE_SEND_THRESHOLD) {
      return; // wait until we have enough to send
    }

    uint256 proceeds = bal.mul(DONEE_PCT).div(100);
    if (!wallet.send(proceeds)) {
      return; // transfer() would throw if out of gas, and we lose the donation; just wait for next one
    }

    uint256 leftover = bal.sub(proceeds);
    if (leftover > 0) {
      if (!dev.send(leftover)) {
        return; // don't throw here either
      }
    }
  }

  // Overrides base ERC23Contract to accept ERC23 compatible tokens
  function tokenFallback(address /*_from*/, uint256 /*_value*/, bytes /*_data*/) external {
    // may have received transfer from ERC23Token.transfer, which calls tokenFallback, so check
    tokenSweep(0x0, msg.sender);
  }

  // Overrides base ERC677Contract
  function receiveApproval(address _from, uint256 _value, address _tokenContract, bytes _data) external returns (bool) {
    tokenSweep(_from, _tokenContract);

    ReceiveApproval(_from, _value, _tokenContract, _data);
    return true;
  }

  // Overrides base ERC677Contract
  function receiveTransfer(address _from, uint256 _value, address _tokenContract, bytes _data) external returns (bool) {
    // may have already swept in ERC23Token.transfer tokenFallback call, so check
    tokenSweep(0x0, _tokenContract);

    ReceiveTransfer(_from, _value, _tokenContract, _data);
    return true;
  }

  // let dev sweep ERC20 tokens (i.e. not ether) which were sent w/o receiveApproval/receiveTransfer
  // don't pass potential token spam to ben, but devs don't mind, so throw them a bone :)
  // permissionless b/c receiver (dev) is hardcoded; can be called internally or externally
  // NOTE: be sure to use _from=0x0 to transfer tokens already in this possession
  function tokenSweep(address _from, address _tokenContract) public {
    StandardToken tok = StandardToken(_tokenContract);
    if(_from == address(0)) {
      uint256 tokBal = tok.balanceOf(this); // check actual balance instead of _value
      if (tokBal > 0) {
        tok.transfer(dev, tokBal);
      }
    } else {
      uint256 tokAllow = tok.allowance(_from, this); // check actual allowance instead of _value
      if (tokAllow > 0) {
        tok.transferFrom(_from, dev, tokAllow);
      }
    }
  }

  /**
   * @dev Allows the current ben to change the ben AND wallet address (overrides & calls Benable).
   * @param newAddr The address to transfer benship to.
   */
  function transferBenship(address newAddr) onlyBen public {
    transferWallet(newAddr);
    super.transferBenship(newAddr); // must be called last (subsequent onlyBen funcs would fail!)
  }

  /**
   * @dev Allows the current ben to change the wallet address only.
   * @param newAddr The address to transfer wallet to.
   */
  function transferWallet(address newAddr) onlyBen public {
    wallet = newAddr;
  }

  /**
   * @dev Allows the dev to one-time launch, iff deployed with startTime == endTime.
   * NOTE: be sure to set after next block will be mined!
   * @param _startTime the new start timestamp
   */
  function onetimeLaunch(uint256 _startTime) external onlyDev {
    require(startTime == endTime);
    require(_startTime >= now);
    require(_startTime < endTime);

    startTime = _startTime;
  }

}
