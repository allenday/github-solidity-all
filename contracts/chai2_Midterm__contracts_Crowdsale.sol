pragma solidity ^0.4.11;

import './utils/SafeMath.sol';
import './Token.sol';
import './Queue.sol';

/**
 * @title Crowdsale
 * @dev Crowdsale is a base contract for managing a token crowdsale.
 * Crowdsales have a start and end timestamps, where investors can make
 * token purchases and the crowdsale will assign them tokens based
 * on a token per ETH rate. Funds collected are forwarded to a wallet
 * as they arrive.
 */
contract Crowdsale {
  using SafeMath for uint256;

  // The token being sold

  // start and end timestamps where investments are allowed (both inclusive)
  uint256 public startTime;
  uint256 public endTime;

  // address where funds are collected
  // address public owner;

  // how many token units a buyer gets per wei
  uint256 public rate;

  // amount of raised money in wei
  uint256 public weiRaised;

  Token public token;
  Queue public queue;

  address public owner;

  /**
   * event for token purchase logging
   * @param purchaser who paid for the tokens
   * @param sender who got the tokens
   * @param value weis paid for purchase
   * @param amount amount of tokens purchased
   */
  event TokenPurchase(address indexed purchaser, address indexed sender, uint256 value, uint256 amount);

  function Crowdsale(uint256 _startTime, uint256 _endTime, uint256 _rate, address _owner, uint maxTime) {

  	// mapping(address => uint256) buyerAddresses;

  	address buyerAddress = msg.sender;
  	owner = _owner;
  	uint256 currentTime;
    uint256 totalSupply;

    require(_startTime >= block.number);
    require(_endTime >= _startTime);
    require(_rate > 0);
    require(buyerAddress != owner);

    currentTime = now;

	queue = new Queue(maxTime);

    token = createTokenContract(buyerAddress, totalSupply);
    startTime = _startTime;
    endTime = _endTime;
    rate = _rate;
    // wallet = _wallet;


  }

  // creates the token to be sold.
  // override this method to have crowdsale of a specific mintable token.
  function createTokenContract(address buyerAddress, uint256 totalSupply) internal returns (Token) {
    return new Token(totalSupply, buyerAddress);
  }

  // fallback function can be used to buy tokens
  function () payable {
    buyTokens(msg.sender);
  }

  // low level token purchase function
  function buyTokens(address buyerAddress) public payable {
    require(buyerAddress != owner);
    require(validPurchase());

    uint256 weiAmount = msg.value;

    // calculate token amount to be created
    uint256 tokens = weiAmount.mul(rate);

    // update state
    weiRaised = weiRaised.add(weiAmount);

    token.addSupply(buyerAddress, tokens);
    TokenPurchase(buyerAddress, owner, weiAmount, tokens);

    forwardFunds();
  }

  // send ether to the fund collection wallet
  // override to create custom fund forwarding mechanisms
  function forwardFunds() internal {
    owner.transfer(msg.value);
  }

  // @return true if the transaction can buy tokens
  function validPurchase() internal constant returns (bool) {
    bool withinPeriod = now >= startTime && now <= endTime;
    bool nonZeroPurchase = msg.value != 0;
    return withinPeriod && nonZeroPurchase;
  }

  // @return true if crowdsale event has ended
  function hasEnded() public constant returns (bool) {
    return now > endTime;
  }


}
