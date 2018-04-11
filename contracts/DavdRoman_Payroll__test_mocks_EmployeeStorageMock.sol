pragma solidity ^0.4.11;

import '../../contracts/Employees/EmployeeStorage.sol';

contract EmployeeStorageMock is EmployeeStorage {

	function mock_resetLatestTokenAllocation(address _address) {
		getEmployee(_address).latestTokenAllocation = 0;
	}

	function mock_resetLatestPayday(address _address) {
		getEmployee(_address).latestPayday = now;
	}

	/// Helper function that requires all fields of an employee to be empty
	/// in order not to throw. Used to test employees are removed completely
	/// without leaving storage residue behind.
	function mock_throwIfNotRemoved(address _address) {
		Employee storage employee = getEmployee(_address);
		require(!employee.exists);
		require(employee.id == 0);
		require(employee.allocatedTokens.length() == 0);
		require(employee.peggedTokens.length() == 0);
		require(employee.salaryTokens.length() == 0);
		require(employee.latestTokenAllocation == 0);
		require(employee.latestPayday == 0);
		require(employee.latestTokenPaydays.length() == 0);
		require(employee.yearlyUSDSalary == 0);
	}
}
