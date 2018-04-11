pragma solidity ^0.4.11;

import './IEmployeeStorage.sol';
import '../Libs/AddressUIntIndexedMappingLib.sol';
import 'zeppelin-solidity/contracts/math/SafeMath.sol';
import 'zeppelin-solidity/contracts/ownership/Ownable.sol';

contract EmployeeStorage is IEmployeeStorage, Ownable {
	using AddressUIntIndexedMappingLib for AddressUIntIndexedMappingLib.Struct;
	using SafeMath for uint;

	struct Employee {
		bool exists;
		uint id;
		address accountAddress;

		AddressUIntIndexedMappingLib.Struct allocatedTokens; // parts per 10000 (100.00%)
		AddressUIntIndexedMappingLib.Struct peggedTokens; // pegged exchange rate (18 decimals)
		AddressUIntIndexedMappingLib.Struct salaryTokens; // calculated monthly salary from allocation, pegging, and yearly USD salary

		uint latestTokenAllocation;
		uint latestPayday;
		AddressUIntIndexedMappingLib.Struct latestTokenPaydays; // latest paydays on a per-token basis

		uint yearlyUSDSalary; // 18 decimals
	}

	uint nextEmployeeId = 1;
	uint employeeCount;
	mapping (uint => Employee) employeesById;
	mapping (address => uint) employeeIdsByAddress;
	uint yearlyUSDSalariesTotal;
	AddressUIntIndexedMappingLib.Struct salaryTokensTotal;

	function getEmployee(address _address) internal constant returns (Employee storage employee) {
		uint employeeId = employeeIdsByAddress[_address];
		return employeesById[employeeId];
	}

	// Modifiers

	modifier existingEmployeeAddress(address _address) {
		require(getEmployee(_address).exists);
		_;
	}

	modifier existingEmployeeId(uint _id) {
		require(employeesById[_id].exists);
		_;
	}

	modifier notExistingEmployeeAddress(address _address) {
		require(!getEmployee(_address).exists);
		_;
	}

	// Add

	function add(address _address, uint _yearlyUSDSalary, uint _startDate) onlyOwner notExistingEmployeeAddress(_address) {
		employeesById[nextEmployeeId].exists = true;
		employeesById[nextEmployeeId].id = nextEmployeeId;
		employeesById[nextEmployeeId].accountAddress = _address;
		employeesById[nextEmployeeId].latestPayday = _startDate;
		employeesById[nextEmployeeId].yearlyUSDSalary = _yearlyUSDSalary;

		employeeIdsByAddress[_address] = nextEmployeeId;

		employeeCount++;
		nextEmployeeId++;
		yearlyUSDSalariesTotal = yearlyUSDSalariesTotal.add(_yearlyUSDSalary);
	}

	// Set

	function setAddress(address _address, address _newAddress) onlyOwner existingEmployeeAddress(_address) notExistingEmployeeAddress(_newAddress) {
		Employee storage employee = getEmployee(_address);
		delete employeeIdsByAddress[_address];
		employee.accountAddress = _newAddress;
		employeeIdsByAddress[_newAddress] = employee.id;
	}

	function setAllocatedToken(address _address, address _token, uint _distribution) onlyOwner existingEmployeeAddress(_address) {
		getEmployee(_address).allocatedTokens.set(_token, _distribution);
	}

	function clearAllocatedAndSalaryTokens(address _address) onlyOwner existingEmployeeAddress(_address) {
		Employee storage employee = getEmployee(_address);
		employee.allocatedTokens.clear();
		uint salaryTokensLength = employee.salaryTokens.length();
		for (uint i; i < salaryTokensLength; i++) {
			address token = employee.salaryTokens.getAddress(0);
			setSalaryToken(_address, token, 0);
		}
	}

	function setPeggedToken(address _address, address _token, uint _value) onlyOwner existingEmployeeAddress(_address) {
		getEmployee(_address).peggedTokens.set(_token, _value);
	}

	function setSalaryToken(address _address, address _token, uint _value) onlyOwner existingEmployeeAddress(_address) {
		Employee storage employee = getEmployee(_address);

		uint totalValue = salaryTokensTotal.getUInt(_token);
		uint employeeValue = employee.salaryTokens.getUInt(_token);
		uint newTotalValue = totalValue.sub(employeeValue).add(_value);

		salaryTokensTotal.set(_token, newTotalValue);
		employee.salaryTokens.set(_token, _value);
	}

	function setLatestTokenAllocation(address _address, uint _date) onlyOwner existingEmployeeAddress(_address) {
		getEmployee(_address).latestTokenAllocation = _date;
	}

	function setLatestPayday(address _address, uint _date) onlyOwner existingEmployeeAddress(_address) {
		getEmployee(_address).latestPayday = _date;
	}

	function setLatestTokenPayday(address _address, address _token, uint _date) onlyOwner existingEmployeeAddress(_address) {
		getEmployee(_address).latestTokenPaydays.set(_token, _date);
	}

	function setYearlyUSDSalary(address _address, uint _salary) onlyOwner existingEmployeeAddress(_address) {
		Employee storage employee = getEmployee(_address);
		yearlyUSDSalariesTotal = yearlyUSDSalariesTotal.sub(employee.yearlyUSDSalary);
		employee.yearlyUSDSalary = _salary;
		yearlyUSDSalariesTotal = yearlyUSDSalariesTotal.add(_salary);
	}

	// Get

	function getCount() constant returns (uint) {
		return employeeCount;
	}

	function getId(address _address) existingEmployeeAddress(_address) constant returns (uint) {
		return getEmployee(_address).id;
	}

	function getAddress(uint _id) existingEmployeeId(_id) constant returns (address) {
		return employeesById[_id].accountAddress;
	}

	function getAllocatedTokenCount(address _address) existingEmployeeAddress(_address) constant returns (uint) {
		return getEmployee(_address).allocatedTokens.length();
	}

	function getAllocatedTokenAddress(address _address, uint _index) existingEmployeeAddress(_address) constant returns (address) {
		return getEmployee(_address).allocatedTokens.getAddress(_index);
	}

	function getAllocatedTokenValue(address _address, address _token) existingEmployeeAddress(_address) constant returns (uint) {
		return getEmployee(_address).allocatedTokens.getUInt(_token);
	}

	function getPeggedTokenCount(address _address) existingEmployeeAddress(_address) constant returns (uint) {
		return getEmployee(_address).peggedTokens.length();
	}

	function getPeggedTokenAddress(address _address, uint _index) existingEmployeeAddress(_address) constant returns (address) {
		return getEmployee(_address).peggedTokens.getAddress(_index);
	}

	function getPeggedTokenValue(address _address, address _token) existingEmployeeAddress(_address) constant returns (uint) {
		return getEmployee(_address).peggedTokens.getUInt(_token);
	}

	function getSalaryTokenCount(address _address) constant returns (uint) {
		return getEmployee(_address).salaryTokens.length();
	}

	function getSalaryTokenAddress(address _address, uint _index) constant returns (address) {
		return getEmployee(_address).salaryTokens.getAddress(_index);
	}

	function getSalaryTokenValue(address _address, address _token) existingEmployeeAddress(_address) constant returns (uint) {
		return getEmployee(_address).salaryTokens.getUInt(_token);
	}

	function getLatestTokenAllocation(address _address) existingEmployeeAddress(_address) constant returns (uint) {
		return getEmployee(_address).latestTokenAllocation;
	}

	function getLatestPayday(address _address) existingEmployeeAddress(_address) constant returns (uint) {
		return getEmployee(_address).latestPayday;
	}

	function getLatestTokenPayday(address _address, address _token) existingEmployeeAddress(_address) constant returns (uint) {
		return getEmployee(_address).latestTokenPaydays.getUInt(_token);
	}

	function getYearlyUSDSalary(address _address) existingEmployeeAddress(_address) constant returns (uint) {
		return getEmployee(_address).yearlyUSDSalary;
	}

	function getYearlyUSDSalariesTotal() constant returns (uint) {
		return yearlyUSDSalariesTotal;
	}

	function getSalaryTokensTotalCount() constant returns (uint) {
		return salaryTokensTotal.length();
	}

	function getSalaryTokensTotalAddress(uint _index) constant returns (address) {
		return salaryTokensTotal.getAddress(_index);
	}

	function getSalaryTokensTotalValue(address _token) constant returns (uint) {
		return salaryTokensTotal.getUInt(_token);
	}

	// Remove

	function remove(address _address) onlyOwner existingEmployeeAddress(_address) {
		Employee storage employee = getEmployee(_address);

		clearAllocatedAndSalaryTokens(_address);
		employee.peggedTokens.clear();
		delete employee.latestTokenAllocation;
		delete employee.latestPayday;
		employee.latestTokenPaydays.clear();
		yearlyUSDSalariesTotal = yearlyUSDSalariesTotal.sub(employee.yearlyUSDSalary);
		delete employee.yearlyUSDSalary;

		delete employee.exists;
		delete employee.id;
		delete employee.accountAddress;

		employeeCount--;
	}
}
