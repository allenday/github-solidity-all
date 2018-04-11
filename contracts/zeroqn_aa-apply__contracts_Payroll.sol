pragma solidity ^0.4.17;

/**
 * @title Payroll
 */

import "./EmployeeServ.sol";
import "./PaymentServ.sol";

import "zeppelin-solidity/contracts/lifecycle/Pausable.sol";


contract Payroll is Pausable {

    address public employeeServ;
    address public paymentServ;

    modifier onlyEmployee() {
        require(
            EmployeeServ(employeeServ).isEmployee(msg.sender)
        );
        _;
    }

    event OnEmployeeAdded(
        uint256 indexed employeeId,
        address account,
        uint256 indexed yearlyUSDSalary
    );
    event OnEmployeeSalaryUpdated(
        uint256 indexed employeeId,
        uint256 indexed yearlyUSDSalary
    );
    event OnEmployeeRemoved(uint256 indexed employeeId, uint256 date);
    event OnAllocationChanged(
        uint256 indexed employeeId,
        address token,
        uint256 alloc
    );
    event OnEthFundsAdded(address indexed from, uint256 indexed amount);
    event OnPaid(uint256 indexed employeeId, uint256 indexed monthlyUSDSalary);

    function Payroll(
        address _employeeServ,
        address _paymentServ
    )
        public
    {
        // constructor
        employeeServ = _employeeServ;
        paymentServ = _paymentServ;
    }

    function getEmployeeCount()
        external view returns (uint256)
    {
        return EmployeeServ(employeeServ).getEmployeeCount();
    }

    function getEmployeeId(address account)
        external view returns (uint256)
    {
        return EmployeeServ(employeeServ).getEmployeeId(account);
    }

    function getEmployee(uint256 employeeId)
        external view returns (bool, address, uint256)
    {
        EmployeeServ serv = EmployeeServ(employeeServ);
        var (active,account,,yearlyUSDSalary) = serv.getEmployee(employeeId);

        return (active, account, yearlyUSDSalary);
    }

    function calculatePayrollBurnrate()
        external view returns (uint256)
    {
        return PaymentServ(paymentServ).calculatePayrollBurnrate();
    }

    function calculatePayrollRunway()
        external view returns (uint256)
    {
        return PaymentServ(paymentServ).calculatePayrollRunway();
    }

    function calculatePayrollRunwayInMonths()
        external view returns (uint256)
    {
        return PaymentServ(paymentServ).calculatePayrollRunwayInMonths();
    }

    function setServices(address _employeeServ, address _paymentServ)
        onlyOwner
        external
    {
        require(_employeeServ != 0x0 && _paymentServ != 0x0);

        employeeServ = _employeeServ;
        paymentServ = _paymentServ;
    }

    function addEmployee(
        address   accountAddress,
        address[] allowedTokens,
        uint256   initialYearlyUSDSalary
    )
        onlyOwner
        external
    {
        uint256 id = EmployeeServ(employeeServ).addEmployee(
            accountAddress,
            allowedTokens,
            initialYearlyUSDSalary
        );

        OnEmployeeAdded(id, accountAddress, initialYearlyUSDSalary);
    }

    function setEmployeeSalary(uint256 employeeId, uint256 yearlyUSDSalary)
        onlyOwner
        external
    {
        EmployeeServ(employeeServ).setEmployeeSalary(
            employeeId,
            yearlyUSDSalary
        );

        OnEmployeeSalaryUpdated(employeeId, yearlyUSDSalary);
    }

    function removeEmployee(uint256 employeeId)
        onlyOwner
        external
    {
        EmployeeServ(employeeServ).removeEmployee(employeeId);

        OnEmployeeRemoved(employeeId, now);
    }

    function addFunds()
        payable
        public
    {
        PaymentServ(paymentServ).addFunds.value(msg.value)(msg.sender);
        OnEthFundsAdded(msg.sender, msg.value);
    }

    function escapeHatch()
        onlyOwner
        external
    {
        PaymentServ(paymentServ).escapeHatch();
    }

    function emergencyWithdraw()
        onlyOwner
        whenPaused
        external
    {
        PaymentServ(paymentServ).emergencyWithdraw(msg.sender);
    }

    function determineAllocation(address[] tokens, uint256[] distribution)
        onlyEmployee
        whenNotPaused
        external
    {
        EmployeeServ eServ = EmployeeServ(employeeServ);
        eServ.determineAllocation(
            msg.sender,
            tokens,
            distribution
        );

        uint256 id = eServ.getEmployeeId(msg.sender);
        for (uint i = 0; i < tokens.length; i++) {
            OnAllocationChanged(id, tokens[i], distribution[i]);
        }
    }

    function payday()
        onlyEmployee
        whenNotPaused
        external
    {
        EmployeeServ eServ = EmployeeServ(employeeServ);
        uint256 id = eServ.getEmployeeId(msg.sender);
        var (,account,monthlyUSDSalary,) = eServ.getEmployee(id);

        PaymentServ(paymentServ).payday(id, account, monthlyUSDSalary);
        OnPaid(id, monthlyUSDSalary);
    }

    function updateExchangeRates()
        external
    {
        PaymentServ(paymentServ).updateExchangeRates();
    }

    function __callback(bytes32 id, string result)
        external
    {
        PaymentServ(paymentServ).setExchangeRateByOraclize(
            msg.sender,
            id,
            result
        );
    }

    /// @notice oraclize use __callback to import data. I haven't found
    /// a way to change it to use a differnt name, so please treat _callback
    /// as setExchangeRate that is defined in PayrollInterface.
    function setExchangeRate(address token, uint256 usdExchangeRate)
        onlyOwner
        external
    {
        PaymentServ(paymentServ).setExchangeRate(token, usdExchangeRate);
    }

    function ()
        payable
        external
    {
        addFunds();
    }

}
