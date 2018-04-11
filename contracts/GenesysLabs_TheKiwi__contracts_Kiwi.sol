pragma solidity >=0.4.15;

import "zeppelin/lifecycle/Pausable.sol";
import "./KiwiUtils.sol";
import "./KiwiInvoices.sol";

/**
 * @title The Kiwi Token
 * @dev ERC20 The Kiwi Token (KIWI)
 *
 * KIWI Tokens are divisible by 1e18 (100 000 000 000 000 000)
 * base units referred to as tuis.
 *
 * KIWI are displayed using 18 decimal places of precision.
 *
 *
 * Tuis are mined on demand as ether is received.
 *
**/

contract Kiwi is KiwiUtils, Pausable, KiwiInvoices {

  event TokensSold(address indexed tokenowner, uint value);

  string public name;           // Set the token name for display
  string public symbol;         // Set the token symbol for display
  uint8 public decimals;        // Set the number of decimals for display

  uint256 public token_eth;     // number of Tokens per ETH
  uint256 public token_value;   // value of 1 Token

  address public company;       // the address that should receive 10% of Tokens

  mapping (address => uint) public pendingWithdrawals;

  uint256 private percentToHold;

  function Kiwi(address _company, uint256 _token_eth, string _name, string _symbol, uint8 _decimals, uint8 _percentToHold) {
    token_eth = _token_eth;
    token_value = 1 ether;    //note that this value is dynamic once contract is deployed
    company = _company;
    name = _name;
    symbol = _symbol;
    decimals = _decimals;
    percentToHold = _percentToHold;
  }

  /**
   * @dev Fallback function that forwards to buyTokens
   *
   */
  function () whenNotPaused public payable {
    buyTokens(msg.sender);
  }

  /**
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender when not paused.
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
  function approve(address _spender, uint256 _value) whenNotPaused public returns (bool) {
    return super.approve(_spender, _value);
  }

  /**
   * @dev Transfer token for a specified address when not paused
   * @param _to The address to transfer to.
   * @param _value The amount to be transferred.
   */
  function transfer(address _to, uint256 _value) whenNotPaused public returns (bool) {
    require(_to != address(0));
    return super.transfer(_to, _value);
  }

  /**
   * @dev Transfer tokens from one address to another when not paused
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
  function transferFrom(address _from, address _to, uint256 _value) whenNotPaused public returns (bool) {
    require(_to != address(0));
    return super.transferFrom(_from, _to, _value);
  }

  /**
   * @dev Function to buy Tokens
   * @param _to The address that will receive the minted tokens
   */
  function buyTokens(address _to) whenNotPaused public payable {
    require(_to != 0x0);

    uint256 tokens = (msg.value * token_eth);

    mint(_to, tokens * (100 - percentToHold) / 100);
    mint(company, tokens * percentToHold / 100);

  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newCompany The address to transfer ownership to.
   */
  function setCompany(address newCompany) onlyOwner public {
    require(newCompany != address(0));
    company = newCompany;
  }

  function sellTokens(uint256 _amount) whenNotPaused public {

    //burn the tokens
    burn(msg.sender, _amount);

    //allow ether to be withdrawn
    pendingWithdrawals[msg.sender] += _amount / token_eth;

    //fire tokens sold event
    TokensSold(msg.sender, _amount);
  }

  /**
  * @return amount of ether that can be withdrawn
  **/
  function checkWithdrawalAvailability(address _address) public constant returns(uint) {
    return pendingWithdrawals[_address];
  }

  function withdraw() {
    uint amount = pendingWithdrawals[msg.sender];
    pendingWithdrawals[msg.sender] = 0;
    msg.sender.transfer(amount);
  }

}
