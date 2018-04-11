pragma solidity ^0.4.17;

import "./EmployeeServLibrary.sol";
import "./UsingDB.sol";
import "./Gateway.sol";


contract EmployeeServ is UsingDB, Gateway {

    using EmployeeServLibrary for address;

    event OnEmployeeAdded(
        uint256 indexed employeeId,
        address account,
        uint256 indexed yearlyUSDSalary
    );
    event OnEmployeeSalaryUpdated(
        uint256 indexed employeeId,
        uint256 indexed yearlyUSDSalary
    );
    event OnEmployeeRemoved(uint256 indexed employeeId);
    event OnAllocationChanged(
        uint256 indexed employeeId,
        address token,
        uint256 alloc
    );

    function EmployeeServ(address _db)
        UsingDB(_db)
        public
    {
    }

    function isEmployee(address account)
        external view returns (bool)
    {
        return db.isEmployee(account);
    }

    function getEmployeeCount()
        external view returns (uint256)
    {
        return db.getEmployeeCount();
    }

    function getEmployeeId(address account)
        external view returns (uint256)
    {
        return db.getEmployeeId(account);
    }

    function getEmployee(uint256 employeeId)
        external view returns (bool     active,
                               address  account,
                               uint256  monthlyUSDSalary,
                               uint256  yearlyUSDSalary)
    {
        return db.getEmployee(employeeId);
    }

    function addEmployee(
        address   account,
        address[] allowedTokens,
        uint256   initialYearlyUSDSalary
    )
        onlyPayrollOrOwner
        external returns (uint256)
    {
        return db.addEmployee(account, allowedTokens, initialYearlyUSDSalary);
    }

    function setEmployeeSalary(uint256 employeeId, uint256 yearlyUSDSalary)
        onlyPayrollOrOwner
        external
    {
        db.setEmployeeSalary(employeeId, yearlyUSDSalary);
    }

    function removeEmployee(uint256 employeeId)
        onlyPayrollOrOwner
        external
    {
        db.removeEmployee(employeeId);
    }

    function determineAllocation(
        address account,
        address[] tokens,
        uint256[] distribution
    )
        onlyPayroll
        external
    {
        db.setEmployeeTokenAllocation(account, tokens, distribution);
    }

    function ()
        payable
        external
    {
        revert();
    }

}
