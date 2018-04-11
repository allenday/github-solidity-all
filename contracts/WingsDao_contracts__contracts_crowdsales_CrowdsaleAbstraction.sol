pragma solidity ^0.4.8;

import "../zeppelin/token/StandardToken.sol";
import "../milestones/MilestonesAbstraction.sol";
import "../zeppelin/Ownable.sol";

contract CrowdsaleAbstraction is StandardToken, Ownable {
  /*
    Only parent
  */
  modifier onlyParent() {
    if (msg.sender != parent) {
      throw;
    }

    _;
  }

  /*
    Check cap
  */
  modifier checkCap() {
    if (cap == true) {
      uint afterFund = safeAdd(msg.value, totalCollected);
      if (afterFund <= milestones.totalAmount()) {
        _;
      } else {
        throw;
      }
    } else {
      _;
    }
  }

  /*
    It's possible to change condition
  */
  modifier isPossibleToModificate() {
    if (lockDataTimestamp != 0 && block.timestamp > lockDataTimestamp) {
      throw;
    }

    _;
  }

  /*
    Crowdsale failed
  */
  modifier isCrowdsaleFailed() {
    if (endTimestamp < block.timestamp && isMinimalReached() == false) {
      _;
    } else {
      throw;
    }
  }

  /*
    Crowdsale completed
  */
  modifier isCrowdsaleCompleted() {
    bool inTime = endTimestamp != 0 && endTimestamp < block.timestamp;

    if (isCapReached() == true || (inTime == true && isMinimalReached() == true)) {
        _;
      } else {
        throw;
      }
  }

  /*
    Crowdsale alive
  */
  modifier isCrowdsaleAlive() {
    if ((startTimestamp < block.timestamp && endTimestamp > block.timestamp) && isCapReached() == false) {
        _;
    } else {
      throw;
    }
  }

  /*
    Only forecaster
  */
  modifier onlyForecasting() {
    if (msg.sender != address(forecasting)) {
      throw;
    }

    _;
  }

  /*
    Struct Vesting Account
  */
  struct VestingAccount {
    address account;
    uint initialPayment;

    uint payment;
    uint latestAllocation;

    uint allocationsCount;
    mapping(uint => uint) allocations;
  }

  /*
    Struct Price change
  */
  struct PriceChange {
    uint timestamp;
    uint price;
  }

  /*
    Vesting accounts list
  */
  mapping(address => VestingAccount) public vestingAccounts;

  /*
    Paritcipiants
  */
  mapping(address => uint) public paritcipiants;

  /*
    Mapping price changing time
  */
  uint public priceChangesLength;
  mapping(uint => PriceChange) public priceChanges;

  /*
    ERC20
  */
  string public name;
  string public symbol;
  uint public decimals = 18;

  /*
    Owner of crowdsale
  */
  address public owner;
  address public parent;

  /*
    Multisignature account
  */
  address public multisig;

  /*
    Contract where milestones placed
  */
  MilestonesAbstraction public milestones;

  /*
    Contract where forecasting placed
  */
  address public forecasting;

  /*
    Total collected amount
  */
  uint public totalCollected;

  /*
    Contract balance
  */
  uint public contractBalance;

  /*
    Price of token
  */
  uint public price;

  /*
    Under cap
  */
  bool public cap;

  /*
    Lock data timestamp
  */
  uint public lockDataTimestamp;

  /*
   Start & end timestamp
  */
  uint public startTimestamp;
  uint public endTimestamp;

  /*
    Reward percent
  */
  uint public rewardPercent;

  /*
    Wings Crowdsale Functional
  */

  /*
    Create tokens for participiant
  */
  function createTokens(address recipient) internal isCrowdsaleAlive() checkCap();

  /*
    Set timestamp limitations
  */
  function setLimitations(uint _lockDataTimestamp, uint _startTimestamp, uint _endTimestamp) onlyParent() isPossibleToModificate();

  /*
    Set forecasting contract
  */
  function setForecasting(address _forecasting) onlyParent() isPossibleToModificate();

  /*
      Vesting
  */

  /*
    Add vesting account
  */
  function addVestingAccount(address _account, uint _initialPayment, uint _payment) onlyOwner() isPossibleToModificate();

  /*
    Add vesting allocation
  */
  function addVestingAllocation(address _account, uint _timestamp) onlyOwner() isPossibleToModificate();

  /*
    Release vesting allocation
  */
  function releaseVestingAllocation() isCrowdsaleCompleted();

  /*
    Get vesting account
  */
  function getVestingAccount(address _account) constant returns (uint, uint, uint);

  /*
    Get vesting
  */
  function getVestingAllocation(address _account, uint _index) constant returns (uint);

  /*
    Bonuses
  */

  /*
    Add price change
  */
  function addPriceChange(uint _timestamp, uint _price) onlyOwner() isPossibleToModificate();


  /*
    Forecasting
  */

  /*
    Give reward to forecaster based on percent from reward percent
  */
  function giveReward(address _account, uint _amount) onlyForecasting() isCrowdsaleCompleted();

  /*
    ETH functions (Payable)
  */

  /*
    Withdraw ETH
  */
  function withdraw(uint _amount) payable onlyOwner() isCrowdsaleCompleted();

  /*
    Payback (only if crowdsale is not success)
  */
  function payback() payable isCrowdsaleFailed();

  /*
    Is cap reached (if there is cap)
  */
  function isCapReached() constant returns (bool);

  /*
    Is minimal goal reached (if there is minimal goal)
  */
  function isMinimalReached() constant returns (bool);
}
