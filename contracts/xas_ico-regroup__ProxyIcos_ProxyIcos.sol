pragma solidity ^0.4.13;

/*

ICO Buyer
========================

Use a contrat as a proxy between the buyer address and group of investors
Original Author: https://github.com/xas
Version : 0.7

*/

import "../BaseIcos.sol";

contract ProxyIcos is BaseIco {
  // Store the amount of ETH deposited by each account.
  mapping (address => uint256) public balances;
  // Track if the owner gets the eth.
  bool public sentEthers;
  // Track whether the contract has bought the tokens yet.
  bool public boughtTokens;
  // Record ETH value of tokens currently held by contract.
  uint256 public contractEthValue;
  // Emergency kill switch in case a critical bug is found.
  bool private killSale;
  function killedContract() constant returns (bool) { return killSale; }
  
  function version() constant returns (string) { return "0.7"; }

  // Earliest time contract is allowed to buy into the crowdsale.
  uint256 public minimalBuyTime = 1506816000;
  // Maximum amount of user ETH contract will accept.  Reduces risk of hard cap related failure.
  uint256 public maxCap = 10000 ether;
  // The developer address.
  address public developer = 0x13c45FE13eC0D4df66DB5e664c6fca19e81DDC92;
  // The developer ratio fee, 0.1% for the poor developper I am, thanks.
  uint256 ratioFees = 1000;
  // The crowdsale address.  Settable by the developer.
  address public addressBuyer;
  // The token address.  Settable by the developer.
  ERC20 public addressToken;
  
  // Allows the developer to set the crowdsale and token addresses.
  function setMaxCap(uint256 _maxCap) onlyOwner {
    // Stop if you've already sent the ethers
    require(!sentEthers);
    // MaxCap must be greater than balance (or 0).
    require(_maxCap > this.balance);
    maxCap = _maxCap;
  }
  
  // Allows the developer to set the crowdsale and token addresses.
  function setAddresses(address _buyer, address _token) onlyOwner {
    // Set the crowdsale and token addresses.
    // I do not stop the address change because some ICO give you an address where deposit the eth but not yet the token address
    if (_buyer != 0x0 && !sentEthers) {
      // You can change the buyer address until the eth are sent
      addressBuyer = _buyer;
    }
    if (!boughtTokens) {
      // You can set the token address until the buyer sent them back
      addressToken = ERC20(_token);
    }
  }
  
  // Allows the boss to shut down everything except withdrawals in emergencies.
  function activateKillSwitch() onlyOwner {
    // Well you cannot kill if you already bought the tokens
    require(!boughtTokens);
    // Irreversibly activate the kill switch.
    killSale = true;
  }
  
// Withdraws all ETH deposited or tokens purchased by the given user and rewards the caller.
  function withdraw(address user) {
    // Store the user's balance prior to withdrawal in a temporary variable.
    uint256 ethToWithdraw = balances[user];
    // If user decide to withdraw its ether before sending them
    if (!sentEthers) {
      // Update the user's balance prior to sending ETH to prevent recursive call.
      balances[user] = 0;
      // Return the user's funds.  Throws on failure to prevent loss of funds.
      user.transfer(ethToWithdraw);
      return;
    }
    // If ethers were sent. But it was cancelled. And the buyer sent back the ethers
    if (sentEthers && this.balance > 0) {
      // Update the user's balance prior to sending ETH to prevent recursive call.
      balances[user] = 0;
      contractEthValue -= ethToWithdraw;
      // Return the user's funds.  Throws on failure to prevent loss of funds.
      user.transfer(ethToWithdraw);
      return;
    }
    // If the buyer sent the tokens to the contract
    if (boughtTokens) {
      // Withdraw the user's tokens.
      // Retrieve current token balance of contract.
      uint256 tokensBalance = addressToken.balanceOf(address(this));
      // Disallow token withdrawals if there are no tokens to withdraw.
      require(tokensBalance != 0);
      // Store the user's token balance in a temporary variable.
      uint256 tokensToWithdraw = (balances[user] * tokensBalance) / contractEthValue;
      // Update the value of tokens currently held by the contract.
      contractEthValue -= balances[user];
      // Update the user's balance prior to sending to prevent recursive call.
      balances[user] = 0;
      // 0.1% fee if contract successfully bought tokens.
      uint256 fee = tokensToWithdraw / ratioFees;
      // Send the fee to the developer.
      require(addressToken.transfer(developer, fee));
      // Send the funds. Throws on failure to prevent loss of funds.
      require(addressToken.transfer(user, tokensToWithdraw - fee));
    }
  }
  
  // Send the ethers to the buyer address.
  function sendToBuyer() onlyOwner {
    // Short circuit to save gas if the contract has already sent the ethers.
    if (sentEthers) revert();
    // Short circuit to save gas if kill switch is active.
    if (killSale) revert();
    // Disallow buying in if the developer hasn't set the sale address yet.
    require(addressBuyer != 0x0);
    // Record the amount of ETH sent as the contract's current value.
    contractEthValue = this.balance;
    // Transfer all the funds to the buyer address to buy tokens.
    addressBuyer.transfer(contractEthValue);
    // Record that the contract has sent the ethers.
    sentEthers = true;
  }
  
  // Notify that the buyer sent the tokens to the contract
  function getTheTokens() {
    // Short circuit to save gas if the contract has not already sent the ethers.
    if (!sentEthers) revert();
    // Verify the tokens balance
    uint256 tokensBalance = addressToken.balanceOf(address(this));
    require(tokensBalance > 0);
    // Record that the contract has bought the tokens.
    boughtTokens = true;
  }
  
  // Default function.  Called when a user sends ETH to the contract.
  function () payable {
    // Disallow deposits if kill switch is active.
    // Unless the sender is the buyer himself (ICO failed, return the ethers)
    require(!killSale || msg.sender == addressBuyer);
    // Only allow deposits if the ethers aren't already sent to the buyer.
    // Unless the sender is the buyer himself (ICO failed, return the ethers)
    require(!sentEthers || msg.sender == addressBuyer);
    // Only allow deposits that won't exceed the contract's ETH cap.
    require(this.balance < maxCap);
    if (!sentEthers) {
      // Update records of deposited ETH to include the received amount.
      // The "if" to avoid wrong balance when buyer return the ethers
      balances[msg.sender] += msg.value;
    }
  }
}