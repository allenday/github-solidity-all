pragma solidity ^0.4.11;

contract IPayroll {
	// Company-only
	function addEmployee(address _address, uint _yearlyUSDSalary, uint _startDate);
	function setEmployeeAddress(uint _id, address _address);
	function setEmployeeSalary(uint _id, uint _yearlyUSDSalary);
	function removeEmployee(uint _id);
	function getEmployeeCount() constant returns (uint);
	function getEmployeeId(address _address) constant returns (uint);
	function getEmployee(uint _id) constant returns (address accountAddress, uint latestTokenAllocation, uint latestPayday, uint yearlyUSDSalary);

	function calculatePayrollBurnrate() constant returns (uint);
	function calculatePayrollRunway() constant returns (uint);

	function escapeHatch(bool _forced);

	// Employee-only
	function changeAddress(address _address);
	function determineAllocation(address[] _tokens, uint[] _distribution);
	function payday();
}
