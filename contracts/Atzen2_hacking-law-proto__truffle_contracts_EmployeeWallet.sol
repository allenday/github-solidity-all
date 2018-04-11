pragma solidity ^0.4.8;


contract EmployeeWallet {
	address public employee;
	address public agencyAddress;
	string public name;
	bool public validContract;
	bool public access;
	uint32 public workHours;
	uint32 public balance;
	uint32 public hWage;
	bool public moneyOk;
	


	function EmployeeWallet(string _name) {
		employee = msg.sender;
		name = _name;

		/* initialization */
		access = false;
		workHours = 0;
		validContract = false;
		balance = 0;
		hWage = 0;
		moneyOk = false;
	}


	function resetWallet() {
		access = false;
		workHours = 0;
		validContract = false;
		balance = 0;
		hWage = 0;
		moneyOk = false;
	}


	/* called from PLAgreements */
	function allowWorking(uint32 _workHours) {
		access = true;
		workHours = _workHours;
	}


	function () payable {

	}


	/* called from AgencyWallet */
	function sendMoney(uint32 amount){
		if(amount == workHours * hWage)
		{
			moneyOk = true;
			balance += amount;
		} 
	}


	/* called from EmpAgreements */
	function validContract(address _agencyAddress, uint32 _hWage) {
		validContract = true;
		agencyAddress = _agencyAddress;
		hWage = _hWage;
	}
}
