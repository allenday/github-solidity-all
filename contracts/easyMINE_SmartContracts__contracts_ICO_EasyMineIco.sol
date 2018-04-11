pragma solidity ^0.4.13;

import "../Token/EasyMineToken.sol";

contract EasyMineIco {

  event TokensSold(address indexed buyer, uint256 amount);
  event TokensReserved(uint256 amount);
  event IcoFinished(uint256 burned);

  struct PriceThreshold {
    uint256 tokenCount;
    uint256 price;
    uint256 tokensSold;
  }

  /* Maximum duration of ICO */
  uint256 public maxDuration;

  /* Minimum start delay in blocks */
  uint256 public minStartDelay;

  /* The owner of this contract */
  address public owner;

  /* The sys address that handles token reservation */
  address public sys;

  /* The reservation address - where reserved tokens will be send */
  address public reservationAddress;

  /* The easyMINE wallet address */
  address public wallet;

  /* The easyMINE token */
  EasyMineToken public easyMineToken;

  /* ICO start block */
  uint256 public startBlock;

  /* ICO end block */
  uint256 public endBlock;

  /* The three price thresholds */
  PriceThreshold[3] public priceThresholds;

  /* Current stage */
  Stages public stage;

  enum Stages {
    Deployed,
    SetUp,
    StartScheduled,
    Started,
    Ended
  }

  modifier atStage(Stages _stage) {
    require(stage == _stage);
    _;
  }

  modifier isOwner() {
    require(msg.sender == owner);
    _;
  }

  modifier isSys() {
    require(msg.sender == sys);
    _;
  }

  modifier isValidPayload() {
    require(msg.data.length == 0 || msg.data.length == 4);
    _;
  }

  modifier timedTransitions() {
    if (stage == Stages.StartScheduled && block.number >= startBlock) {
      stage = Stages.Started;
    }
    if (stage == Stages.Started && block.number >= endBlock) {
      finalize();
    }
    _;
  }

  function EasyMineIco(address _wallet)
    public {
    require(_wallet != 0x0);

    owner = msg.sender;
    wallet = _wallet;
    stage = Stages.Deployed;
  }

  /* Fallback function */
  function()
    public
    payable
    timedTransitions {
    if (stage == Stages.Started) {
      buyTokens();
    } else {
      revert();
    }
  }

  function setup(address _easyMineToken, address _sys, address _reservationAddress, uint256 _minStartDelay, uint256 _maxDuration)
    public
    isOwner
    atStage(Stages.Deployed)
  {
    require(_easyMineToken != 0x0);
    require(_sys != 0x0);
    require(_reservationAddress != 0x0);
    require(_minStartDelay > 0);
    require(_maxDuration > 0);

    priceThresholds[0] = PriceThreshold(2000000  * 10**18, 0.00070 * 10**18, 0);
    priceThresholds[1] = PriceThreshold(2000000  * 10**18, 0.00075 * 10**18, 0);
    priceThresholds[2] = PriceThreshold(23000000 * 10**18, 0.00080 * 10**18, 0);

    easyMineToken = EasyMineToken(_easyMineToken);
    sys = _sys;
    reservationAddress = _reservationAddress;
    minStartDelay = _minStartDelay;
    maxDuration = _maxDuration;

    // Validate token balance
    assert(easyMineToken.balanceOf(this) == maxTokensSold());

    stage = Stages.SetUp;
  }

  function maxTokensSold()
    public
    constant
    returns (uint256) {
    uint256 total = 0;
    for (uint8 i = 0; i < priceThresholds.length; i++) {
      total += priceThresholds[i].tokenCount;
    }
    return total;
  }

  function totalTokensSold()
    public
    constant
    returns (uint256) {
    uint256 total = 0;
    for (uint8 i = 0; i < priceThresholds.length; i++) {
      total += priceThresholds[i].tokensSold;
    }
    return total;
  }

  /* Schedules start of the ICO */
  function scheduleStart(uint256 _startBlock)
    public
    isOwner
    atStage(Stages.SetUp)
  {
    // Start allowed minimum 5000 blocks from now
    require(_startBlock > block.number + minStartDelay);

    startBlock = _startBlock;
    endBlock = startBlock + maxDuration;
    stage = Stages.StartScheduled;
  }

  function updateStage()
    public
    timedTransitions
    returns (Stages)
  {
    return stage;
  }

  function buyTokens()
    public
    payable
    isValidPayload
    timedTransitions
    atStage(Stages.Started)
  {
    require(msg.value > 0);

    uint256 amountRemaining = msg.value;
    uint256 tokensToReceive = 0;

    for (uint8 i = 0; i < priceThresholds.length; i++) {
      uint256 tokensAvailable = priceThresholds[i].tokenCount - priceThresholds[i].tokensSold;
      uint256 maxTokensByAmount = amountRemaining * 10**18 / priceThresholds[i].price;

      uint256 tokens;
      if (maxTokensByAmount > tokensAvailable) {
        tokens = tokensAvailable;
        amountRemaining -= (priceThresholds[i].price * tokens) / 10**18;
      } else {
        tokens = maxTokensByAmount;
        amountRemaining = 0;
      }
      priceThresholds[i].tokensSold += tokens;
      tokensToReceive += tokens;
    }

    assert(tokensToReceive > 0);

    if (amountRemaining != 0) {
      assert(msg.sender.send(amountRemaining));
    }

    assert(wallet.send(msg.value - amountRemaining));
    assert(easyMineToken.transfer(msg.sender, tokensToReceive));

    if (totalTokensSold() == maxTokensSold()) {
      finalize();
    }

    TokensSold(msg.sender, tokensToReceive);
  }

  function reserveTokens(uint256 tokenCount)
    public
    isSys
    timedTransitions
    atStage(Stages.Started)
  {
    require(tokenCount > 0);

    uint256 tokensRemaining = tokenCount;

    for (uint8 i = 0; i < priceThresholds.length; i++) {
      uint256 tokensAvailable = priceThresholds[i].tokenCount - priceThresholds[i].tokensSold;

      uint256 tokens;
      if (tokensRemaining > tokensAvailable) {
        tokens = tokensAvailable;
      } else {
        tokens = tokensRemaining;
      }
      priceThresholds[i].tokensSold += tokens;
      tokensRemaining -= tokens;
    }

    uint256 tokensReserved = tokenCount - tokensRemaining;

    assert(easyMineToken.transfer(reservationAddress, tokensReserved));

    if (totalTokensSold() == maxTokensSold()) {
      finalize();
    }

    TokensReserved(tokensReserved);
  }

  /* Transfer any ether accidentally left in this contract */
  function cleanup()
    public
    isOwner
    timedTransitions
    atStage(Stages.Ended)
  {
    assert(owner.send(this.balance));
  }

  function finalize()
    private
  {
    stage = Stages.Ended;

    // burn unsold tokens
    uint256 balance = easyMineToken.balanceOf(this);
    easyMineToken.burn(balance);
    IcoFinished(balance);
  }

}
