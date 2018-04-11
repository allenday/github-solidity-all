pragma solidity ^0.4.4;

import 'zeppelin-solidity/contracts/token/MintableToken.sol';
import 'zeppelin-solidity/contracts/math/SafeMath.sol';
import 'zeppelin-solidity/contracts/ownership/Ownable.sol';

import './AthenaLabsToken.sol';

contract AthenaLabsICO is Ownable, Pausable {
  using SafeMath for uint256;

  uint256 public startTime;
  uint256[7] public endOfRounds;
  uint256 public endTime;
  uint256 public maxFinalizationTime;

  // multisig addr for transfers
  address public mainWallet;

  // addrs for whitelist, remove from whitelist
  address[3] public adminAccounts;

  // rate ATH : ETH
  uint256 public rate = 800;

  // limited slots for Early bonuses
  uint256[8] public earlySlots = [10, 5, 5, 5, 3, 3, 2, 2];

  AthenaLabsToken public token;

  uint256 public weiTotalAthSold;
  uint256 public weiTotalBountiesGiven;
  uint256 public weiTotalAthSoldCap = 192000000 * 10 ** 18;
  uint256 public weiTotalBountiesGivenCap = 8000000 * 10 ** 18;
  uint256 public weiOneToken = 10 ** 18;

  bool public isFinalized = false;

  uint256 public maxUnpauseTime;

  // ID authorization of Investors

  struct Investor {
    uint256 etherInvested;
    uint256 athReceived;
    uint256 etherInvestedPending;
    uint256 athReceivedPending;
    bool authorized;
    bool exists; // this is to indicate, whether this investor is new
  }

  mapping (address => Investor) public investors;
  address[] investor_list;

  event Finalized();
    /**
   * event for token purchase logging
   * @param investor who paid for the tokens
   * @param value weis paid for purchase
   * @param amount amount of tokens purchased
   */
  event TokenPurchase(address indexed investor, uint256 value, uint256 amount);

  /* Same as TokenPurchase, but not sent. Only reserved and waiting for approval. */
  event TokenPurchasePending(address indexed investor, uint256 value, uint256 amount);

  // When an investor is approved to invest more than 2.1ETH
  event Authorized(address indexed investor);
    /**
   * event for giving away tokens as bounty
   * @param beneficiary who got the tokens
   * @param amount amount of tokens given
   */
  event TokenBounty(address indexed beneficiary, uint256 amount);
  /**
  * event for refunding ETH, when the investor is not approved
  */
  event Refunded(address indexed investor, uint256 weiEthReturned, uint256 weiAthBurned);

  function AthenaLabsICO( uint256 _startTime
                        , uint256[7] _endOfRounds
                        , uint256 _maxFinalizationTime
                        , address _mainWallet
                        , address[3] _adminAccounts) payable public {
    require(_startTime   >= now);
    require(_endOfRounds.length == 7);
    require(_endOfRounds[0] >= _startTime);
    require(_endOfRounds[1] >= _endOfRounds[0]);
    require(_endOfRounds[2] >= _endOfRounds[1]);
    require(_endOfRounds[3] >= _endOfRounds[2]);
    require(_endOfRounds[4] >= _endOfRounds[3]);
    require(_endOfRounds[5] >= _endOfRounds[4]);
    require(_endOfRounds[6] >= _endOfRounds[5]);
    require(_maxFinalizationTime >= _endOfRounds[6]);
    require(_mainWallet != 0x0);
    require(_adminAccounts[0] != 0x0);
    require(_adminAccounts[1] != 0x0);
    require(_adminAccounts[2] != 0x0);

    startTime   = _startTime;
    endOfRounds = _endOfRounds;
    endTime     = _endOfRounds[6];

    mainWallet  = _mainWallet;

    adminAccounts      = _adminAccounts;
    maxFinalizationTime = _maxFinalizationTime;

    token = new AthenaLabsToken();
    token.setMaxFinalizationTime(_maxFinalizationTime);

    // mint tokens for bounties and keep it on this contract
    token.mint(this, weiTotalAthSoldCap.add(weiTotalBountiesGivenCap));
    token.finishMinting();
  }

  modifier canAdmin() {
    require(  (msg.sender == adminAccounts[0])
            ||(msg.sender == adminAccounts[1])
            ||(msg.sender == adminAccounts[2])
            ||(msg.sender == owner));
    _;
  }

  function setAdminAccounts(address[3] _adminAccounts) onlyOwner public {
    adminAccounts = _adminAccounts;
  }

  function setMainWallet(address _mainWallet) onlyOwner public {
    mainWallet = _mainWallet;
  }

  // admins can pause (but not unpause!)
  function pause() canAdmin whenNotPaused public {
    paused = true;
    maxUnpauseTime = now + 7*24*60*60; // +1 week
    Pause();
  }

  function unpause() whenPaused public {
    if (maxUnpauseTime > now) {
      require(msg.sender == owner);
    }
    paused = false;
    Unpause();
  }

  // fallback function can be used to buy tokens
  function () whenNotPaused payable public {
    buyTokens();
  }

  // low level token purchase function
  function buyTokens() public whenNotPaused payable {
    require(msg.sender != 0x0);
    require(validPurchase());

    uint256 weiEther = msg.value;

    // calculate token amount to be created and reduce slots for limited bonuses
    // here we are abusing, that Athena is also 18 decimals
    uint256 weiTokens = weiEther.mul(rate).add(calculateAndRegisterBonuses(weiEther));

    require(weiTotalAthSold.add(weiTokens) <= weiTotalAthSoldCap);

    // decide what to do depending on whether this investor is already authorized
    Investor storage investor = investors[msg.sender];
    if (!investor.exists) {
      investor_list.push(msg.sender);
      investor.exists = true;
    }
    if (   investor.authorized
        || investor.etherInvested.add(weiEther) <= 2100 finney) {
      investor.etherInvested = investor.etherInvested.add(weiEther);
      investor.athReceived = investor.athReceived.add(weiTokens);
      weiTotalAthSold = weiTotalAthSold.add(weiTokens);
      TokenPurchase(msg.sender, weiEther, weiTokens);
      token.transfer(msg.sender, weiTokens);
      mainWallet.transfer(weiEther);
    } else {
      /* if not authorized yet and over authorization limit, received ETH is
      saved on this contract instead and ATH is minted to this contract */
      investor.etherInvestedPending = investor.etherInvestedPending.add(weiEther);
      investor.athReceivedPending = investor.athReceivedPending.add(weiTokens);
      TokenPurchasePending(msg.sender, weiEther, weiTokens);
      // pending ATH is reserved an this contract
      weiTotalAthSold = weiTotalAthSold.add(weiTokens);
      // pending ETH stays on this contract
    }
  }

  // @return true if the transaction can buy tokens
  function validPurchase() internal constant returns (bool) {
    bool withinPeriod = now >= startTime && now <= endTime;
    bool nonTrivialPurchase = msg.value > 100 finney;
    return withinPeriod && nonTrivialPurchase;
  }

  function authorizeOne(address investor_addr) canAdmin whenNotPaused public {
    Investor storage investor = investors[investor_addr];
    require(!investor.authorized);
    uint256 athToSend = investor.athReceivedPending;
    uint256 ethToForward = investor.etherInvestedPending;
    investor.etherInvested = investor.etherInvested.add(ethToForward);
    investor.athReceived = investor.athReceived.add(athToSend);
    investor.authorized = true;
    investor.etherInvestedPending = 0;
    investor.athReceivedPending = 0;
    if (!investor.exists) {
      investor_list.push(investor_addr);
      investor.exists = true;
    }
    Authorized(investor_addr);
    if (ethToForward > 0) {
      TokenPurchase(investor_addr, ethToForward, athToSend);
      mainWallet.transfer(ethToForward);
      token.transfer(investor_addr, athToSend);
    }
  }

  function authorize(address[] investor_addrs) canAdmin whenNotPaused public {
    require(investor_addrs.length <= 100);
    Investor storage investor;
    for (uint i = 0; i < investor_addrs.length; i++) {
      investor = investors[investor_addrs[i]];
      if (!investor.exists) {
        investor_list.push(investor_addrs[i]);
        investor.exists = true;
      }
      if (!investor.authorized) {
        uint256 athToSend = investor.athReceivedPending;
        uint256 ethToForward = investor.etherInvestedPending;
        investor.etherInvested = investor.etherInvested.add(ethToForward);
        investor.athReceived = investor.athReceived.add(athToSend);
        investor.authorized = true;
        investor.etherInvestedPending = 0;
        investor.athReceivedPending = 0;
        Authorized(investor_addrs[i]);
        if (ethToForward > 0) {
          TokenPurchase(investor_addrs[i], ethToForward, athToSend);
          mainWallet.transfer(ethToForward);
          token.transfer(investor_addrs[i], athToSend);
        }
      }
    }
  }

  function refund(address investor_addr) canAdmin public {
    Investor storage investor = investors[investor_addr];
    require(!investor.authorized);
    // when returning, fee is taken for the additional effort/trouble
    uint256 ethToForward = 100 finney;
    uint256 ethToReturn = investor.etherInvestedPending.sub(ethToForward);
    require(ethToReturn > 0);
    uint256 athToRefund = investor.athReceivedPending;
    investor.etherInvestedPending = 0;
    investor.athReceivedPending = 0;
    Refunded(investor_addr, ethToReturn, athToRefund);
    // burn tokens reserved for this investment
    weiTotalAthSold = weiTotalAthSold.sub(athToRefund);
    // forward fee
    mainWallet.transfer(ethToForward);
    // return investment
    investor_addr.transfer(ethToReturn);
  }

  // @return true if crowdsale event has ended
  function hasEnded() public constant returns (bool) {
    return now > endTime;
  }

  function giveTokensOne(address beneficiary, uint256 weiTokens) canAdmin public {
    require(beneficiary != 0x0);
    require(weiTokens >= 5 * weiOneToken);
    require(weiTotalBountiesGiven.add(weiTokens) <= weiTotalBountiesGivenCap);
    weiTotalBountiesGiven = weiTotalBountiesGiven.add(weiTokens);
    TokenBounty(beneficiary, weiTokens);
    token.transfer(beneficiary, weiTokens);
  }

  function giveTokens(address[] beneficiaries, uint256 weiTokens) canAdmin public {
    require(beneficiaries.length <= 100);
    require(weiTokens >= 5 * weiOneToken);
    require(weiTotalBountiesGiven.add(weiTokens.mul(beneficiaries.length)) <= weiTotalBountiesGivenCap);
    weiTotalBountiesGiven = weiTotalBountiesGiven.add(weiTokens.mul(beneficiaries.length));
    for (uint i = 0; i < beneficiaries.length; i++) {
      TokenBounty(beneficiaries[i], weiTokens);
      token.transfer(beneficiaries[i], weiTokens);
    }
  }

  function calculateAndRegisterBonuses(uint256 weiEther) internal returns (uint256) {
    uint256 time     = calculateTimeBonuses(weiEther);
    uint256 quantity = calculateQuantityBonuses(weiEther);
    uint256 early    = calculateAndRegisterEarlyBonuses(weiEther);
    return time.add(quantity).add(early);
  }

  function calculateTimeBonuses(uint256 weiEther) internal constant returns (uint256) {
    if (startTime <= now && now < endOfRounds[0]) {
      return weiEther.mul(320); // 40% of rate
    }
    if (endOfRounds[0] <= now && now < endOfRounds[1]) {
      return weiEther.mul(200); // 25% of rate
    }
    if (endOfRounds[1] <= now && now < endOfRounds[2]) {
      return weiEther.mul(120); // 415 of rate
    }
    if (endOfRounds[2] <= now && now < endOfRounds[3]) {
      return weiEther.mul(80); // 10% of rate
    }
    if (endOfRounds[3] <= now && now < endOfRounds[4]) {
      return weiEther.mul(48); // 6% of rate
    }
    if (endOfRounds[4] <= now && now < endOfRounds[5]) {
      return weiEther.mul(24); // 3% of rate
    }
    return 0;
  }

  function calculateQuantityBonuses(uint256 weiEther) internal constant returns (uint256) {
    if (weiEther >= 500 ether) {
      return weiEther.mul(240); // 30% of rate
    }
    if (weiEther >= 125 ether) {
      return weiEther.mul(120); // 15% of rate
    }
    if (weiEther >= 50 ether) {
      return weiEther.mul(40); // 5% of rate
    }
    return 0;
  }

  function calculateAndRegisterEarlyBonuses(uint256 weiEther) internal returns (uint256) {
    if (weiEther >= 1000 ether && earlySlots[7] > 0) {
      earlySlots[7] = earlySlots[7].sub(1);
      return 500000 * weiOneToken;
    }
    if (weiEther >= 750 ether && earlySlots[6] > 0) {
      earlySlots[6] = earlySlots[6].sub(1);
      return 240000 * weiOneToken;
    }
    if (weiEther >= 500 ether && earlySlots[5] > 0) {
      earlySlots[5] = earlySlots[5].sub(1);
      return 110000 * weiOneToken;
    }
    if (weiEther >= 250 ether && earlySlots[4] > 0) {
      earlySlots[4] = earlySlots[4].sub(1);
      return 50000 * weiOneToken;
    }
    if (weiEther >= 100 ether && earlySlots[3] > 0) {
      earlySlots[3] = earlySlots[3].sub(1);
      return 18000 * weiOneToken;
    }
    if (weiEther >= 50 ether && earlySlots[2] > 0) {
      earlySlots[2] = earlySlots[2].sub(1);
      return 7000 * weiOneToken;
    }
    if (weiEther >= 20 ether && earlySlots[1] > 0) {
      earlySlots[1] = earlySlots[1].sub(1);
      return 2800 * weiOneToken;
    }
    if (weiEther >= 10 ether && earlySlots[0] > 0) {
      earlySlots[0] = earlySlots[0].sub(1);
      return 1200 * weiOneToken;
    }
    return 0;
  }

  /**
   * @dev Must be called after crowdsale ends, to do some extra finalization
   * work. Calls the contract's finalization function.
   */
  function finalize() public {
    require((msg.sender == owner) || (maxFinalizationTime <= now));
    require(!isFinalized);
    require(hasEnded());

    finalization();
    Finalized();

    isFinalized = true;
  }

  function finalization() internal {
    // unsold tokens are burned
    token.burn(weiTotalAthSoldCap.sub(weiTotalAthSold));
    // tokens are released for public trading
    token.finalize();
  }

  function withdraw() public {
    require(isFinalized);
    if (now < maxFinalizationTime) {
      require(msg.sender == owner);
    } else {
      require(  (msg.sender == adminAccounts[0])
              ||(msg.sender == adminAccounts[1])
              ||(msg.sender == adminAccounts[2])
              ||(msg.sender == owner));
    }
    msg.sender.transfer(this.balance);
  }

  function destroy() onlyOwner public {
    require(isFinalized);
    token.transfer(owner, token.balanceOf(this));
    token.transferOwnership(owner);
    selfdestruct(owner);
  }
}
