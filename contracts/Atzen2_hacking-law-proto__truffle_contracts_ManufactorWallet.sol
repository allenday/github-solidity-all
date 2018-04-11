pragma solidity ^0.4.8;

import "./AgencyWallet.sol";


contract ManufactorWallet {
	address manufactor;
	address agencyAddress;
	string public name;
	bool public validContract;
	uint32 public balance;
	uint32 public emplyeHWage;
	uint32 public workHours;
	uint32 public workedHours;	


	function ManufactorWallet(string _name) {
		manufactor = msg.sender;
		name = _name;
		validContract = false;
		uint32 emplyeHWage = 0;
		balance = 0;
		workHours = 0;
		workedHours = 0;
	}


	function resetWallet() {
		validContract = false;
		uint32 emplyeHWage = 0;
		balance = 0;
		workHours = 0;
		workedHours = 0;
	}


	/* call to increase worked hours */
	function updateHours() {
		if(validContract){
			workedHours++;

			if(workedHours >= workHours) {
				balance -= workHours * emplyeHWage; 
				
				AgencyWallet aw = AgencyWallet(agencyAddress);
				aw.pipeMoney();

				validContract = false;
			}
		} 
	}



	function () payable {

	}


	/* called from PLAgreements */
	function validContract(uint32 _emplyeHWage, uint32 _workHours, address _agencyAddress) {
		validContract = true;
		emplyeHWage = _emplyeHWage;
		workHours = _workHours;
		agencyAddress = _agencyAddress;
	}
}