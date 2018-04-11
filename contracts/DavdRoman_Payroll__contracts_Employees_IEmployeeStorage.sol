pragma solidity ^0.4.11;

contract IEmployeeStorage {
	// Add
	function add(address _address, uint _yearlyUSDSalary, uint _startDate);

	// Set
	function setAddress(address _address, address _newAddress);

	function setAllocatedToken(address _address, address _token, uint _distribution);
	function setPeggedToken(address _address, address _token, uint _value);
	function setSalaryToken(address _address, address _token, uint _value);

	function clearAllocatedAndSalaryTokens(address _address);

	function setLatestTokenAllocation(address _address, uint _date);
	function setLatestPayday(address _address, uint _date);
	function setLatestTokenPayday(address _address, address _token, uint _date);
	function setYearlyUSDSalary(address _address, uint _salary);

	// Get
	function getCount() constant returns (uint);
	function getId(address _address) constant returns (uint);
	function getAddress(uint _id) constant returns (address);

	function getAllocatedTokenCount(address _address) constant returns (uint);
	function getAllocatedTokenAddress(address _address, uint _index) constant returns (address);
	function getAllocatedTokenValue(address _address, address _token) constant returns (uint);

	function getPeggedTokenCount(address _address) constant returns (uint);
	function getPeggedTokenAddress(address _address, uint _index) constant returns (address);
	function getPeggedTokenValue(address _address, address _token) constant returns (uint);

	function getSalaryTokenCount(address _address) constant returns (uint);
	function getSalaryTokenAddress(address _address, uint _index) constant returns (address);
	function getSalaryTokenValue(address _address, address _token) constant returns (uint);

	function getLatestTokenAllocation(address _address) constant returns (uint);
	function getLatestPayday(address _address) constant returns (uint);
	function getLatestTokenPayday(address _address, address _token) constant returns (uint);
	function getYearlyUSDSalary(address _address) constant returns (uint);

	function getYearlyUSDSalariesTotal() constant returns (uint);

	function getSalaryTokensTotalCount() constant returns (uint);
	function getSalaryTokensTotalAddress(uint _index) constant returns (address);
	function getSalaryTokensTotalValue(address _token) constant returns (uint);

	// Remove
	function remove(address _address);
}
