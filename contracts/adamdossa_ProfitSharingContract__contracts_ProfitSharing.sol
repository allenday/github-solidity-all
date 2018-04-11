pragma solidity ^0.4.11;

import './MiniMeToken.sol';
import '../installed_contracts/zeppelin/contracts/math/SafeMath.sol';
import '../installed_contracts/zeppelin/contracts/Ownership/Ownable.sol';

contract ProfitSharing is Ownable {
  using SafeMath for uint;

  event DividendDeposited(address indexed _depositor, uint256 _blockNumber, uint256 _amount, uint256 _totalSupply, uint256 _dividendIndex);
  event DividendClaimed(address indexed _claimer, uint256 _dividendIndex, uint256 _claim);
  event DividendRecycled(address indexed _recycler, uint256 _blockNumber, uint256 _amount, uint256 _totalSupply, uint256 _dividendIndex);

  MiniMeToken public miniMeToken;

  uint256 public RECYCLE_TIME = 1 years;

  struct Dividend {
    uint256 blockNumber;
    uint256 timestamp;
    uint256 amount;
    uint256 claimedAmount;
    uint256 totalSupply;
    bool recycled;
    mapping (address => bool) claimed;
  }

  Dividend[] public dividends;

  mapping (address => uint256) dividendsClaimed;

  modifier validDividendIndex(uint256 _dividendIndex) {
    require(_dividendIndex < dividends.length);
    _;
  }

  function ProfitSharing(address _miniMeToken) {
    miniMeToken = MiniMeToken(_miniMeToken);
  }

  function depositDividend() payable
  onlyOwner
  {
    uint256 currentSupply = miniMeToken.totalSupplyAt(block.number);
    uint256 dividendIndex = dividends.length;
    uint256 blockNumber = SafeMath.sub(block.number, 1);
    dividends.push(
      Dividend(
        blockNumber,
        getNow(),
        msg.value,
        0,
        currentSupply,
        false
      )
    );
    DividendDeposited(msg.sender, blockNumber, msg.value, currentSupply, dividendIndex);
  }

  function claimDividend(uint256 _dividendIndex) public
  validDividendIndex(_dividendIndex)
  {
    Dividend dividend = dividends[_dividendIndex];
    require(dividend.claimed[msg.sender] == false);
    require(dividend.recycled == false);
    uint256 balance = miniMeToken.balanceOfAt(msg.sender, dividend.blockNumber);
    uint256 claim = balance.mul(dividend.amount).div(dividend.totalSupply);
    dividend.claimed[msg.sender] = true;
    dividend.claimedAmount = SafeMath.add(dividend.claimedAmount, claim);
    if (claim > 0) {
      msg.sender.transfer(claim);
      DividendClaimed(msg.sender, _dividendIndex, claim);
    }
  }

  function claimDividendAll() public {
    require(dividendsClaimed[msg.sender] < dividends.length);
    for (uint i = dividendsClaimed[msg.sender]; i < dividends.length; i++) {
      if ((dividends[i].claimed[msg.sender] == false) && (dividends[i].recycled == false)) {
        dividendsClaimed[msg.sender] = SafeMath.add(i, 1);
        claimDividend(i);
      }
    }
  }

  function recycleDividend(uint256 _dividendIndex) public
  onlyOwner
  validDividendIndex(_dividendIndex)
  {
    Dividend dividend = dividends[_dividendIndex];
    require(dividend.recycled == false);
    require(dividend.timestamp < SafeMath.sub(getNow(), RECYCLE_TIME));
    dividends[_dividendIndex].recycled = true;
    uint256 currentSupply = miniMeToken.totalSupplyAt(block.number);
    uint256 remainingAmount = SafeMath.sub(dividend.amount, dividend.claimedAmount);
    uint256 dividendIndex = dividends.length;
    uint256 blockNumber = SafeMath.sub(block.number, 1);
    dividends.push(
      Dividend(
        blockNumber,
        getNow(),
        remainingAmount,
        0,
        currentSupply,
        false
      )
    );
    DividendRecycled(msg.sender, blockNumber, remainingAmount, currentSupply, dividendIndex);
  }

  //Function is mocked for tests
  function getNow() internal constant returns (uint256) {
    return now;
  }

}
