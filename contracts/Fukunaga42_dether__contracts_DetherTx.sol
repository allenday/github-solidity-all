pragma solidity ^0.4.8;

import "./SafeMath.sol";

contract DetherTx {
  struct Details {
      // if possible check if it is an uniq username
      string username;
      uint price;
      uint balance;
      uint volumeTrade;
      uint nbTrade;
      string localizationGpsX;
      string localizationGpsY;
      uint commentIpfsId;
  }

  address[] public listAdressesUsers;

  mapping(address => Details) public users;

  event Transfer (address indexed _from, address indexed _to, uint256 _value);

  function DetherTx() {
  }

  function sendCoin (address receiver, uint amount) returns(bool sufficient) {
    if (users[msg.sender].balance < amount) return false;
    users[msg.sender].balance = SafeMath.safeSub(users[msg.sender].balance, amount);
    users[msg.sender].volumeTrade = SafeMath.safeAdd(users[msg.sender].volumeTrade, amount);
    users[receiver].volumeTrade = SafeMath.safeAdd(users[receiver].volumeTrade, amount);
    ++users[receiver].nbTrade;
    ++users[msg.sender].nbTrade;
    uint amountWithoutFees = SafeMath.safeSub(amount, (amount * 1/100));
    users[receiver].balance = SafeMath.safeAdd(users[receiver].balance, amountWithoutFees);
    Transfer(msg.sender, receiver, amountWithoutFees);

    return true;
  }

  function getBalance () constant returns(uint) {
    return users[msg.sender].balance;
  }

  function getVolume () constant returns(uint) {
    return users[msg.sender].volumeTrade;
  }

  function getNbTrade () constant returns(uint) {
    return users[msg.sender].nbTrade;
  }


  function deposit () payable returns (uint) {
    return  users[msg.sender].balance += msg.value;
    //return SafeMath.safeAdd(users[msg.sender].balance,msg.value );
  }

  /// add and change the wallet of a passager
  function addAccount
  (
    string _username,
    uint _price,
    string _localizationGpsX,
    string _localizationGpsY,
    uint _commentIpfsId
  ) payable returns (
    string,
    uint,
    string,
    string,
    uint
  ) {
     Details details = users[msg.sender];
     details.username = _username;
     details.price = _price;
     details.balance += msg.value;
     details.volumeTrade = 0;
     details.nbTrade = 0;
     details.localizationGpsX = _localizationGpsX;
     details.localizationGpsY = _localizationGpsY;
     details.commentIpfsId = _commentIpfsId;

     ++listAdressesUsers.length;
     listAdressesUsers[listAdressesUsers.length-1] = msg.sender;

     return (
       _username,
       _price
       _localizationGpsX,
       _localizationGpsY,
       _commentIpfsId
     );
  }

  function withdraw (uint _amount) {
    if (users[msg.sender].balance < _amount) throw;
    // It is important to set this to zero because the recipient
    // can call this function again as part of the receiving call
    // before `send` returns.

    //users[msg.sender].balance -= _amount;
    users[msg.sender].balance = SafeMath.safeSub(users[msg.sender].balance,_amount);

    var amount = _amount;

    if(!msg.sender.send(amount)) throw;
  }

  function getAddressesAccounts () constant returns (address[]) {
    return listAdressesUsers;
  }

  // fallback
  function () payable {}
}
