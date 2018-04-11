pragma solidity ^0.4.13;

import "../Token/Token.sol";

contract EasyMineTokenWallet {

  uint256 constant public VESTING_PERIOD = 180 days;
  uint256 constant public DAILY_FUNDS_RELEASE = 15000 * 10**18; // 0.5% * 3M tokens = 15k tokens a day

  address public owner;
  address public withdrawalAddress;
  Token public easyMineToken;
  uint256 public startTime;
  uint256 public totalWithdrawn;

  modifier isOwner() {
    require(msg.sender == owner);
    _;
  }

  function EasyMineTokenWallet() {
    owner = msg.sender;
  }

  function setup(address _easyMineToken, address _withdrawalAddress)
    public
    isOwner
  {
    require(_easyMineToken != 0x0);
    require(_withdrawalAddress != 0x0);

    easyMineToken = Token(_easyMineToken);
    withdrawalAddress = _withdrawalAddress;
    startTime = now;
  }

  function withdraw(uint256 requestedAmount)
    public
    isOwner
    returns (uint256 amount)
  {
    uint256 limit = maxPossibleWithdrawal();
    uint256 withdrawalAmount = requestedAmount;
    if (requestedAmount > limit) {
      withdrawalAmount = limit;
    }

    if (withdrawalAmount > 0) {
      if (!easyMineToken.transfer(withdrawalAddress, withdrawalAmount)) {
        revert();
      }
      totalWithdrawn += withdrawalAmount;
    }

    return withdrawalAmount;
  }

  function maxPossibleWithdrawal()
    public
    constant
    returns (uint256)
  {
    if (now < startTime + VESTING_PERIOD) {
      return 0;
    } else {
      uint256 daysPassed = (now - (startTime + VESTING_PERIOD)) / 86400;
      uint256 res = DAILY_FUNDS_RELEASE * daysPassed - totalWithdrawn;
      if (res < 0) {
        return 0;
      } else {
        return res;
      }
    }
  }

}
