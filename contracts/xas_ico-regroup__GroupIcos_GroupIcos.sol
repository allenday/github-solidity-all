pragma solidity ^0.4.13;

/*

ICO Buyer
========================

Buys tokens from an ico, for a group.
Original Author: /u/Cintix
Modifications : https://github.com/xas
Contributions : https://github.com/VinceBCD
Version : 0.7.2

*/

import "../BaseIcos.sol";

contract GroupIcos is BaseIco {
  // Store the amount of ETH deposited by each account.
  mapping (address => uint256) public balances;
  // Track whether the contract has bought the tokens yet.
  bool public boughtTokens;
  // Record ETH value of tokens currently held by contract.
  uint256 public contractEthValue;
  // Emergency kill switch in case a critical bug is found.
  bool private killSale;
  function killedContract() constant returns (bool) { return killSale; }
  
  function version() constant returns (string) { return "0.7.2"; }

  // Earliest time contract is allowed to buy into the crowdsale.
  uint256 private minimalBuyTime = 1504982472;
  function startBuyTime() constant returns (uint256) { return minimalBuyTime; }
  // Maximum amount of user ETH contract will accept.  Reduces risk of hard cap related failure.
  uint256 public maxCap = 30000 ether;
  // The developer address.
  address public developer = 0x13c45FE13eC0D4df66DB5e664c6fca19e81DDC92;
  // The developer ratio fee, 0.1% for the poor developper I am, thanks.
  uint256 ratioFees = 1000;
  // The crowdsale address.  Settable by the developer.
  address public addressSale;
  // The token address.  Settable by the developer.
  ERC20 public addressToken;
  
  // Allows the developer to set the crowdsale and token addresses.
  function setAddresses(address _sale, address _token) onlyOwner {
    // Only allow setting the addresses once.
    require(addressSale == 0x0);
    // Set the crowdsale and token addresses.
    addressSale = _sale;
    addressToken = ERC20(_token);
  }
  
  // Allows the boss to shut down everything except withdrawals in emergencies.
  function activateKillSwitch() onlyOwner {
    // Well you cannot kill if you already bought the tokens
    require(!boughtTokens);
    // Irreversibly activate the kill switch.
    killSale = true;
  }
  
  // Allows the boss to shut down everything except withdrawals in emergencies.
  function setBuyTime(uint256 _newTime) onlyOwner {
    // Well you cannot modify the time if you already bought the tokens
    require(!boughtTokens);
    // Irreversibly activate the kill switch.
    minimalBuyTime = _newTime;
  }
  
  // Withdraws all ETH deposited or tokens purchased by the given user and rewards the caller.
  function withdraw(address user) {
    // Only allow withdrawals after the contract has had a chance to buy in.
    require(boughtTokens || now > minimalBuyTime + 1 hours);
    // Short circuit to save gas if the user doesn't have a balance.
    if (balances[user] == 0) revert();
    // If the contract is killed
    // If the contract still didn't go into the ico
    // If the contract failed to buy into the sale
    // ==> withdraw the user's ETH.
    if (killSale || !boughtTokens) {
      // Store the user's balance prior to withdrawal in a temporary variable.
      // less the withdraw fees
      uint256 ethToWithdraw = balances[user];
      // Update the user's balance prior to sending ETH to prevent recursive call.
      balances[user] = 0;
      // Return the user's funds.  Throws on failure to prevent loss of funds.
      user.transfer(ethToWithdraw);
    } else {
      // Withdraw the user's tokens if the contract has purchased them.
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
  
  // Buys tokens in the crowdsale and rewards the caller, callable by anyone.
  function sendToIco() {
    // Short circuit to save gas if the contract has already bought tokens.
    if (boughtTokens) revert();
    // Short circuit to save gas if the earliest buy time hasn't been reached.
    if (now < minimalBuyTime) revert();
    // Short circuit to save gas if kill switch is active.
    if (killSale) revert();
    // Disallow buying in if the developer hasn't set the sale address yet.
    require(addressSale != 0x0);
    // Record the amount of ETH sent as the contract's current value.
    contractEthValue = this.balance;
    // Transfer all the funds (less the bounties) to the crowdsale address
    // to buy tokens.  Throws if the crowdsale hasn't started yet or has
    // already completed, preventing loss of funds.
    var sendEths = addressSale.call.value(contractEthValue);
    require(sendEths());
    //addressSale.send(contractEthValue);
    // Record that the contract has bought the tokens.
    boughtTokens = true;
  }
  
  // Default function.  Called when a user sends ETH to the contract.
  function () payable {
    // Disallow deposits if kill switch is active.
    require(!killSale);
    // Only allow deposits if the contract hasn't already purchased the tokens.
    require(!boughtTokens);
    // Only allow deposits that won't exceed the contract's ETH cap.
    require(this.balance < maxCap);
    // Update records of deposited ETH to include the received amount.
    balances[msg.sender] += msg.value;
  }
}