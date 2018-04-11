pragma solidity ^0.4.4;

contract SplitSend {
    address owner;
    address beneficiary_one;
    address beneficiary_two;
    bool locked;

    function SplitSend(address toWhom1, address toWhom2) payable {
        owner = msg.sender;
        beneficiary_one = toWhom1;
        beneficiary_two = toWhom2;
    }

    modifier OwnerOnly() {
      if (msg.sender != owner) throw;
      _;
    }

    modifier NoReentrancy() {
      if (locked) throw;
      locked = true;
      _;
      locked = false;
    }

    function sendWei() payable OwnerOnly NoReentrancy returns (bool) {
        uint sendAmount  = (msg.value - (msg.value % 2)) / 2;
        if ( sendAmount > 0 && beneficiary_one.send(sendAmount) && beneficiary_two.send(sendAmount) ) { return true; } else { throw; } 
    }

    function killMe() OwnerOnly {
      selfdestruct(owner);
    }

    // fallback function 
    function () payable {}
} 
