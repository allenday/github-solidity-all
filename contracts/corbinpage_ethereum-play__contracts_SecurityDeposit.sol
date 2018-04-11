pragma solidity ^0.4.2;

import "./ConvertLib.sol";

// This is just a simple example of a coin-like contract.
// It is not standards compatible and cannot be expected to talk to other
// coin/token contracts. If you want to create a standards-compliant
// token, see: https://github.com/ConsenSys/Tokens. Cheers!

contract SecurityDeposit {
	address landlord;
	address tenant;

	uint balance;
	uint percentageLandlord;

	bool landlordSignOff;
	bool tenantSignOff;

  function SecurityDeposit(address _landlord, address _tenant, uint deposit) {
      landlord = _landlord;
      tenant = _tenant;
      balance = deposit;
  }

  function alterBalance(uint newBalance) {
    if (msg.sender == landlord && newBalance < balance) {
    	balance = newBalance;
    }
    else if (msg.sender == tenant && newBalance > balance) {
    	balance = newBalance;
    }
  }

  function giveSignOff() {
		if(msg.sender == landlord) {
			landlordSignOff = true;
		}
		else if(msg.sender == tenant) {
			tenantSignOff = true;
		}
  }

	// function resolveDeposit() external {
	// 	if(landlordSignOff && tenantSignOff)
	// 		payOut();
	// }

	function payOut() internal {
		uint landlordAmount = balance * (percentageLandlord / 100);
		uint tenantAmount = balance - landlordAmount;

		if(landlordAmount > 0 )
			bool landlordSuccess = landlord.send(landlordAmount);

		if(tenantAmount > 0 )
			bool tenantSuccess = tenant.send(tenantAmount);
	}

}
