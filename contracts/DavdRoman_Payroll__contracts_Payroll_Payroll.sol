pragma solidity ^0.4.11;

import './IPayroll.sol';
import '../Employees/EmployeeStorage.sol';
import '../Exchange/IExchange.sol';
import '../Tokens/ERC20.sol';
import 'zeppelin-solidity/contracts/math/SafeMath.sol';
import 'zeppelin-solidity/contracts/ownership/Ownable.sol';

contract Payroll is IPayroll, Ownable {
	using SafeMath for uint;

	IEmployeeStorage public employeeStorage;
	IExchange public exchange;

	uint public allocationFrequency;
	uint public paydayFrequency;

	// Modifiers

	modifier validAddress(address _address) {
		require(_address != 0x0);
		_;
	}

	modifier higherThanZeroUInt(uint _uint) {
		require(_uint > 0);
		_;
	}

	// Init/setters

	function Payroll(address _exchange, uint _allocationFrequency, uint _paydayFrequency) {
		setEmployeeStorage(new EmployeeStorage());
		setExchange(_exchange);
		allocationFrequency = _allocationFrequency > 0 ? _allocationFrequency : 180 days; // defaults to 6 months
		paydayFrequency = _paydayFrequency > 0 ? _paydayFrequency : 30 days; // defaults to 1 month
	}

	function setEmployeeStorage(address _newEmployeeStorage) onlyOwner validAddress(_newEmployeeStorage) {
		employeeStorage = IEmployeeStorage(_newEmployeeStorage);
	}

	function setExchange(address _newExchange) onlyOwner validAddress(_newExchange) {
		exchange = IExchange(_newExchange);
	}

	function () payable { }

	// Company functions

	/// Adds a new employee.
	///
	/// @param _address the initial address for the employee to receive
	/// their salary.
	/// @param _yearlyUSDSalary the initial yearly USD salary, expressed
	/// with 18 decimals.
	/// i.e. $43500.32 = 4350032e16
	function addEmployee(address _address, uint _yearlyUSDSalary, uint _startDate) onlyOwner validAddress(_address) higherThanZeroUInt(_yearlyUSDSalary) {
		employeeStorage.add(_address, _yearlyUSDSalary, _startDate);
	}

	function setEmployeeAddress(uint _id, address _address) onlyOwner validAddress(_address) {
		address employeeAddress = employeeStorage.getAddress(_id);
		employeeStorage.setAddress(employeeAddress, _address);
	}

	function setEmployeeSalary(uint _id, uint _yearlyUSDSalary) onlyOwner higherThanZeroUInt(_yearlyUSDSalary) {
		address employeeAddress = employeeStorage.getAddress(_id);
		employeeStorage.setYearlyUSDSalary(employeeAddress, _yearlyUSDSalary);
		determineSalaryTokens(employeeAddress);
	}

	function determineSalaryTokens(address _employeeAddress) private {
		uint allocatedTokenCount = employeeStorage.getAllocatedTokenCount(_employeeAddress);

		// calculate new salary
		for (uint i = 0; i < allocatedTokenCount; i++) {
			// fetch info to calculate token salary
			address allocatedToken = employeeStorage.getAllocatedTokenAddress(_employeeAddress, i);
			uint allocation = employeeStorage.getAllocatedTokenValue(_employeeAddress, allocatedToken);
			uint peggedRate = employeeStorage.getPeggedTokenValue(_employeeAddress, allocatedToken);

			// assert validity
			assert(allocatedToken != 0x0);
			assert(allocation > 0);
			assert(peggedRate > 0);

			// calculate monthly salary
			uint monthlyUSDSalary = employeeStorage.getYearlyUSDSalary(_employeeAddress).div(12);
			uint monthlyUSDSalaryAllocation = monthlyUSDSalary.mul(allocation).div(10000);
			uint monthlySalaryTokens = exchange.exchange(allocatedToken, monthlyUSDSalaryAllocation, peggedRate);

			// assign salary tokens
			employeeStorage.setSalaryToken(_employeeAddress, allocatedToken, monthlySalaryTokens);
		}
	}

	function removeEmployee(uint _id) onlyOwner {
		employeeStorage.remove(employeeStorage.getAddress(_id));
	}

	function getEmployeeCount() onlyOwner constant returns (uint) {
		return employeeStorage.getCount();
	}

	function getEmployeeId(address _address) onlyOwner validAddress(_address) constant returns (uint) {
		return employeeStorage.getId(_address);
	}

	function getEmployee(uint _id) onlyOwner constant returns (address accountAddress, uint latestTokenAllocation, uint latestPayday, uint yearlyUSDSalary) {
		accountAddress = employeeStorage.getAddress(_id);
		latestTokenAllocation = employeeStorage.getLatestTokenAllocation(accountAddress);
		latestPayday = employeeStorage.getLatestPayday(accountAddress);
		yearlyUSDSalary = employeeStorage.getYearlyUSDSalary(accountAddress);
	}

	/// Monthly USD amount spent in salaries.
	function calculatePayrollBurnrate() onlyOwner constant returns (uint) {
		return employeeStorage.getYearlyUSDSalariesTotal().div(12);
	}

	/// Days until the contract can run out of funds.
	function calculatePayrollRunway() onlyOwner constant returns (uint) {
		uint shortestTokenRunwayInMonths;

		uint salaryTokensTotalCount = employeeStorage.getSalaryTokensTotalCount();

		for (uint i; i < salaryTokensTotalCount; i++) {
			address token = employeeStorage.getSalaryTokensTotalAddress(i);
			uint tokenBalance = ERC20(token).balanceOf(this);
			uint salaryTokenTotal = employeeStorage.getSalaryTokensTotalValue(token);

			// if we don't have enough tokens for all of the salaries for that
			// token, our runway is 0 days.
			if (tokenBalance < salaryTokenTotal) {
				return 0;
			}

			uint runwayInMonths = tokenBalance.div(salaryTokenTotal);

			// if runway is 0 (unassigned), assign directly
			// otherwise assign only if the new runway is lower.
			if (shortestTokenRunwayInMonths == 0) {
				shortestTokenRunwayInMonths = runwayInMonths;
			} else if (runwayInMonths < shortestTokenRunwayInMonths) {
				shortestTokenRunwayInMonths = runwayInMonths;
			}
		}

		return shortestTokenRunwayInMonths.mul(30); // convert to days
	}

	function escapeHatch(bool _forced) onlyOwner {
		uint salaryTokensTotalCount = employeeStorage.getSalaryTokensTotalCount();
		bool tokenTransfersSucceeded = true;

		for (uint i; i < salaryTokensTotalCount; i++) {
			address token = employeeStorage.getSalaryTokensTotalAddress(i);
			uint tokenBalance = ERC20(token).balanceOf(this);
			if (tokenBalance > 0 && !ERC20(token).transfer(owner, tokenBalance)) {
				tokenTransfersSucceeded = false;
			}
		}

		if (tokenTransfersSucceeded || _forced) {
			selfdestruct(owner);
		}
	}

	// Employee functions

	function changeAddress(address _address) validAddress(_address) {
		address employeeAddress = msg.sender;
		employeeStorage.setAddress(employeeAddress, _address);
	}

	/// Determines allocation of ERC20 tokens as an employee's salary.
	///
	/// @param _tokens specifies the ERC20 token addresses.
	/// @param _distribution is an array of percentages expressed as integers
	/// with a max sum of 10000 (100.00%)
	/// i.e. [5000, 3000, 2000]
	function determineAllocation(address[] _tokens, uint[] _distribution) {
		require(_tokens.length == _distribution.length);

		// check total distribution adds up to exactly 100%
		uint totalDistribution = 0;
		for (uint d = 0; d < _distribution.length; d++) { totalDistribution += _distribution[d]; }
		require(totalDistribution == 10000);

		// fetch employee address
		address employeeAddress = msg.sender;

		// check latest reallocation was > 6 months ago
		uint latestTokenAllocation = employeeStorage.getLatestTokenAllocation(employeeAddress);
		assert(now.sub(latestTokenAllocation) >= allocationFrequency);

		// clean up old allocation and salary
		employeeStorage.clearAllocatedAndSalaryTokens(employeeAddress);

		// set new allocation
		for (uint t = 0; t < _tokens.length; t++) {
			address token = _tokens[t];
			employeeStorage.setAllocatedToken(employeeAddress, token, _distribution[t]);

			// peg rate (new tokens only)
			if (employeeStorage.getPeggedTokenValue(employeeAddress, token) == 0) {
				uint tokenExchangeRate = exchange.exchangeRates(token);
				assert(tokenExchangeRate > 0);
				employeeStorage.setPeggedToken(employeeAddress, token, tokenExchangeRate);
			}
		}

		// set new salary tokens
		determineSalaryTokens(employeeAddress);

		// updates allocation date
		employeeStorage.setLatestTokenAllocation(employeeAddress, now);
	}

	function payday() {
		address employeeAddress = msg.sender;

		// check if payday is due
		uint latestPayday = employeeStorage.getLatestPayday(employeeAddress);
		assert(now.sub(latestPayday) >= paydayFrequency);

		// fetch and pay
		uint salaryTokenCount = employeeStorage.getSalaryTokenCount(employeeAddress);
		bool salaryFullyPaid = true;

		for (uint i; i < salaryTokenCount; i++) {
			// fetch token address
			address token = employeeStorage.getSalaryTokenAddress(employeeAddress, i);

			// check latest token payday, skip if not due
			uint latestTokenPayday = employeeStorage.getLatestTokenPayday(employeeAddress, token);

			if (now.sub(latestTokenPayday) < paydayFrequency) {
				continue;
			}

			// check funds for token are sufficient, skip if not
			uint tokenBalance = ERC20(token).balanceOf(this);
			uint tokenSalary = employeeStorage.getSalaryTokenValue(employeeAddress, token);

			if (tokenBalance < tokenSalary) {
				salaryFullyPaid = false;
				continue;
			}

			// pay employee
			employeeStorage.setLatestTokenPayday(employeeAddress, token, now); // set date before payment to prevent re-entrancy attacks
			if (!ERC20(token).transfer(employeeAddress, tokenSalary)) {
				salaryFullyPaid = false;
				// payment failed, revert back to previous payday date
				// for the employee to have another chance to get paid
				// some other time
				employeeStorage.setLatestTokenPayday(employeeAddress, token, latestTokenPayday);
			}
		}

		// seal the global payday date if all payments succeeded
		if (salaryFullyPaid) {
			employeeStorage.setLatestPayday(employeeAddress, now);
		}
	}
}
