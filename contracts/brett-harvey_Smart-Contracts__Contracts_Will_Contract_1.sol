pragma solidity ^0.4.15;

contract WillCoin {
  mapping (address => uint256) public balanceOf;
  // balanceOf[address] = 5;

  string public standard = "WillCoin v1.0";
  string public name;
  string public symbol;
  uint8 public decimal; // Respresents up to 18 decimal points

  // Constructor which allows for users to specify the details regarding thier custom token.
  function WillCoin() {
    // Adds the inital supply to the senders account.
    balanceOf[msg.sender] = 10000;
    name = "Will Contract";
    symbol = "WIL";
    decimal = 8;
  }

  function tranfer(address _to, uint _value) {
    // Deduct the value from the sender
    balanceOf[msg.sender] -= _value;
    // Add the value to the receivers account.
    balanceOf[_to] += _value;
  }
}

contract EstateTransactions is WillCoin {
  address public estate;

  string public name_of_recipient;
  string public date_of_creation;
  string public date_of_expiration;
  address public recipient_address;
  int public amount_to_send;

  function EstateTransactions(string name_of_will, string creationDate,
    string expirationDate, address receiverAddress, int amount) {
      estate = msg.sender;
      name_of_recipient = name_of_will;
      date_of_creation = creationDate;
      date_of_expiration = expirationDate;
      recipient_address = receiverAddress;
      amount_to_send = amount;
  }

  modifier estateOwnerOnly() {
    if (estate != msg.sender) // throw;
    _;
  }
}
