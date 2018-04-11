pragma solidity ^0.4.6;

contract Bank {
  address owner;
  string public name;

  Order[] public orders;

  struct Order {
    address customerAddress;
    uint256 amount;
    string transactionType;
  }

  function Bank(string _name) payable {
    name = _name;
    owner = msg.sender;
  }

  function() payable {}

  function customerExchangeFiat(uint256 _amount, address _userAddress, string _transactionType) {
    Order memory newOrder = Order({customerAddress:_userAddress,amount:_amount, transactionType:_transactionType});
    orders.push(newOrder);
    if(!_userAddress.send(_amount)) {
      throw;
      }
  }

  function customerExchangeEther(uint256 _amount, address _userAddress, string _transactionType) payable {
    Order memory newOrder = Order({customerAddress:_userAddress,amount:_amount, transactionType:_transactionType});
    orders.push(newOrder);
  }
}