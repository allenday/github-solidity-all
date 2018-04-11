pragma solidity ^0.4.11;

// ADD: you may need the interface of some contract to interact with it . . .
import "./ERCToken.sol";

contract TokenExchange {
  /*
  *  Data structures
  */

  struct SellOrder {
    uint numTokens;
    uint pricePerToken;
  }

  // Can be a seller or a buyer!
  struct User {
    mapping (address => uint) tokenBalance;
    // ADD: mapping for keeping track of the sell orders for some token the user may be selling
    mapping (address => SellOrder) sellOrders;
    // ADD: variable for keeping track of a users balance in Ether (from tokens they have sold)
    uint256 balanceInEther;
  }

  mapping (address => User) users;


  //@dev Allows anyone to transfer previously-approved tokens to this exchange.
	//@param _token Token address where approve(exchangeAddress, _amount) was called
	//@param _amount Amount of tokens being deposited, that have already been approved in the token contract
  function depositToken(address _token, uint _amount) public {
    ERCToken token = ERCToken(_token);
    require(token.transferFrom(msg.sender, this, _amount));
    users[msg.sender].tokenBalance[_token] += _amount;

    // HINT 1: make sure you are calling transferFrom on the token contract and checking the result.
    // HINT 2: don't forget to cast the _token address to a variable you can call functions on . . .
    // HINT 3: check out the FAQ for info about casting (and if you are confused about this function).
  }

  //@dev Allows anyone to sell token that they have already deposited in the exchange
  //@param _token The token that has been previous deposited and is going to be sold
  //@param _amount The number of _tokens being sold
  //@param _costPerToken The cost, in Wei, per token being sold
  function sellTokens(address _token, uint _amount, uint _costPerToken) public {
    require(_amount > 0);
    require(users[msg.sender].tokenBalance[_token] >= _amount);
    users[msg.sender].sellOrders[_token] = SellOrder({numTokens: _amount, pricePerToken: _costPerToken});
  }


  //@dev Allows someone to buy tokens from an someone who is selling them, for the specified price
  //@param _seller Address of user to buy the tokens from
  //@param _token Address of token to buy
  //@param _amount The number of tokens to purchase.
  function buyToken(address _seller, address _token, uint _amount) public payable {
      require(msg.value > 0);
      uint256 etherCost = _amount * users[_seller].sellOrders[_token].pricePerToken;

      //ensure token in Sell Order meet needs of Buyer
      require(users[_seller].sellOrders[_token].numTokens >= _amount);

      //ensure the seller still has enough tokens to sell
      require(users[_seller].tokenBalance[_token] >= _amount);

      //ensure buyer has enough money
      require(msg.value >= etherCost);

      users[msg.sender].tokenBalance[_token] += _amount;
      users[_seller].tokenBalance[_token] -= _amount;
      users[_seller].balanceInEther += etherCost;
      users[_seller].sellOrders[_token].numTokens -= _amount;
  }

  //@dev Allows anyone to withdraw tokens this exchange holds on their behalf
	//@param _token Address of token being withdrawn
	//@param _amount Amount of tokens being withdrawn
  function withdrawToken(address _token, uint _amount) public {
    ERCToken token = ERCToken(_token);

    require(_amount > 0);

    //now approve that jawn
    token.approve(msg.sender, _amount);

    //make sure they have enough token to withdraw as they want
    if(users[msg.sender].tokenBalance[_token] >= _amount){
      users[msg.sender].tokenBalance[_token] -= _amount;
      token.transferFrom(this, msg.sender, _amount);
    }


  }

  //@dev Allows anyone to withdraw any Ether held by this exchange on their behalf
  function withdrawEther() public {
    uint256 amount = users[msg.sender].balanceInEther;
    users[msg.sender].balanceInEther = 0;
    msg.sender.transfer(amount);
  }


  /*
  *   Read functions
  */

  //Allows anyone to check a token balance of a specific user on the exchange.
	//@param _owner Address of user to check balance of.
	//@param _token Address of token to check balance of _owner for.
	//@return Returns amount of _token held by the exchange on behalf of the _owner.
  function getTokenBalance(address _owner, address _token) public returns (uint balance) {
      return users[_owner].tokenBalance[_token];
  }

  //Allows anyone to check the ether balance of someone on this exchange.
	//@param _owner Address of user to check balance of.
	//@return Returns amount of ether held by this exchange on behalf of the user
  function getEtherBalance(address _owner) public returns (uint balance) {
      return users[_owner].balanceInEther;
  }

}
