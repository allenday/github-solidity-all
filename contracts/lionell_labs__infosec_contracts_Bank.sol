pragma solidity ^0.4.15;

contract Bank {
  mapping(address => uint) userBalances;
  uint public totalBankBalance;

  function Bank() public {
    totalBankBalance = 0;
  }

  function getUserBalance(address user) public view returns(uint) {
    return userBalances[user];
  }

  function addToBalance() public payable {
    userBalances[msg.sender] += msg.value;
    totalBankBalance += msg.value;
  }

  function withdrawBalance() public {
    var amountToWithdraw = userBalances[msg.sender];
    if (amountToWithdraw == 0) return;

    require(msg.sender.call.value(amountToWithdraw)());
    totalBankBalance -= userBalances[msg.sender];
    userBalances[msg.sender] = 0;
  }
}

