pragma solidity ^0.4.8;

import "./EmployeeWallet.sol";



contract AgencyWallet {
	address agency; // agency account address
	address employeeAddress;
	string public name;
	bool public validEAContract; 
	bool public validPLAContract;
	uint32 public balance;
	uint32 public emplyeHWage;
	uint32 public emplyeHWage2; // from manufacturer point of view
	uint32 public workHours;
	

	/* Constructor */
	function AgencyWallet(string _name) {
		agency = msg.sender;
		name = _name;

		/* initialization */
		validEAContract = false;
		validPLAContract = false;
		uint32 emplyeHWage = 0;
		uint32 emplyeHWage2 = 0;
		balance = 0;
		workHours = 0;
	}



	function resetWallet() {
		validEAContract = false;
		validPLAContract = false;
		balance = 0;
		emplyeHWage = 0;
		emplyeHWage2 = 0;
		workHours = 0;
	}


	/* function to enable ether reception */
	function () payable {

	}


	/* called from PLAgreement contract
		used to split money and send the rest to the employee */
	function pipeMoney(){
		uint32 money1 = emplyeHWage * workHours;
		uint32 money2 = emplyeHWage2 * workHours;
		
		balance += money2 - money1;

		EmployeeWallet ew = EmployeeWallet(employeeAddress);
		ew.sendMoney(money1);
	}


	/* called from EmpAgreements contract 
		confirms the validity of the employe agreement contract
	function validEAContract(uint32 _emplyeHWage, address _employeeAddress) {
		emplyeHWage = _emplyeHWage;
		validEAContract = true;
		employeeAddress = _employeeAddress;
	}


	/* called from PLAgreements contract 
		confirms the validity of the temporary work contract
	function validPLAContract(uint32 _emplyeHWage2, uint32 _workHours) {
		validPLAContract = true;
		emplyeHWage2 = _emplyeHWage2;
		workHours = _workHours;
	}
}