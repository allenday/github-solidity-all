pragma solidity ^0.4.6;

contract Conference {

  address Organizer;
  mapping (address => uint) RegistrantsPaid;
  uint public Registrants;
  uint Quota;

  event Deposit(address from, uint amount);
  event Refund(address to, uint amount);

  function Conference() {
    Organizer = msg.sender;
    Quota = 5;
    Registrants = 0;
  }

  function GetQuota() constant returns(uint) {
    return Quota;
  }

  function BuyTicket() payable {
    if (msg.value > 0) {
      if (Registrants < Quota && RegistrantsPaid[msg.sender] == 0) {
        RegistrantsPaid[msg.sender] = msg.value;
        Registrants++;
        Deposit(msg.sender, msg.value);
      }
      else {
        if (!msg.sender.send(msg.value)) {
          throw;
        }
      }
    }
  }

  function ChangeQuota(uint newquota) public {
    if (msg.sender != Organizer) {
      throw;
    }

    Quota = newquota;
  }

  function RefundTicket(address recipient, uint amount) public
  {
    if (msg.sender != Organizer) {
      throw;
    }

    if (RegistrantsPaid[recipient] == amount) {
      address myAddress = this;

      if (myAddress.balance >= amount) {
        if (recipient.send(amount))
        {
          Refund(recipient, amount);
          RegistrantsPaid[recipient] = 0;
          Registrants--;
        }
      }
    }
  }

  function Destroy() {
    if (msg.sender == Organizer) {
      // without this funds could be locked in the contract forever!
      suicide(Organizer);
    }
  }
}
