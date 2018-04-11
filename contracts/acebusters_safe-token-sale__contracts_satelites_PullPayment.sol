pragma solidity 0.4.11;


import '../SafeMath.sol';
import "../ownership/Ownable.sol";
import "../controller/ControllerInterface.sol";

/**
 * @title PullPayment
 * @dev Base contract supporting async send for pull payments.
 */
contract PullPayment is Ownable {
  using SafeMath for uint256;


  uint public dailyLimit = 1000000000000000000000;  // 1 ETH
  uint public lastDay;
  uint public spentToday;

  // 8bytes date, 24 bytes value
  mapping(address => uint256) internal payments;

  modifier onlyNutz() {
    require(msg.sender == ControllerInterface(owner).nutzAddr());
    _;
  }

  modifier whenNotPaused () {
    require(!ControllerInterface(owner).paused());
     _;
  }

  function balanceOf(address _owner) constant returns (uint256 value) {
    return uint192(payments[_owner]);
  }

  function paymentOf(address _owner) constant returns (uint256 value, uint256 date) {
    value = uint192(payments[_owner]);
    date = (payments[_owner] >> 192);
    return;
  }

  /// @dev Allows to change the daily limit. Transaction has to be sent by wallet.
  /// @param _dailyLimit Amount in wei.
  function changeDailyLimit(uint _dailyLimit) public onlyOwner {
      dailyLimit = _dailyLimit;
  }

  function changeWithdrawalDate(address _owner, uint256 _newDate)  public onlyOwner {
    // allow to withdraw immediately
    // move witdrawal date more days into future
    payments[_owner] = (_newDate << 192) + uint192(payments[_owner]);
  }

  function asyncSend(address _dest) public payable onlyNutz {
    require(msg.value > 0);
    uint256 newValue = msg.value.add(uint192(payments[_dest]));
    uint256 newDate;
    if (isUnderLimit(msg.value)) {
      uint256 date = payments[_dest] >> 192;
      newDate = (date > now) ? date : now;
    } else {
      newDate = now.add(3 days);
    }
    spentToday = spentToday.add(msg.value);
    payments[_dest] = (newDate << 192) + uint192(newValue);
  }


  function withdraw() public whenNotPaused {
    address untrustedRecipient = msg.sender;
    uint256 amountWei = uint192(payments[untrustedRecipient]);

    require(amountWei != 0);
    require(now >= (payments[untrustedRecipient] >> 192));
    require(this.balance >= amountWei);

    payments[untrustedRecipient] = 0;

    untrustedRecipient.transfer(amountWei);
  }

  /*
   * Internal functions
   */
  /// @dev Returns if amount is within daily limit and resets spentToday after one day.
  /// @param amount Amount to withdraw.
  /// @return Returns if amount is under daily limit.
  function isUnderLimit(uint amount) internal returns (bool) {
    if (now > lastDay.add(24 hours)) {
      lastDay = now;
      spentToday = 0;
    }
    // not using safe math because we don't want to throw;
    if (spentToday + amount > dailyLimit || spentToday + amount < spentToday) {
      return false;
    }
    return true;
  }

}
