pragma solidity ^0.4.17;

/**
 * @title PayrollInterface
 * @dev This abstract contract acts as interface for Payroll contract. It
 * defines function signatures that are used in Payroll contract.
 * @notice For the sake of simplicity, here we assume USD is a ERC20 token.
 * Also lets assume we can 100% trust the exchange rate oracle.
 */


contract PayrollInterface {

    /* OWNER ONLY */
    function addEmployee(
        address   accountAddress,
        address[] allowedTokens,
        uint256   initialYearlyUSDSalary
    ) external;

    function setEmployeeSalary(
        uint256 employeeId,
        uint256 yearlyUSDSalary
    ) external;

    function removeEmployee(uint256 employeeId) external;

    function addFunds() payable external;
    function escapeHatch() external;
    // TODO: Use approveAndCall or ERC223 tokenFallback
    // function addTokenFunds()

    function getEmployeeCount() external constant returns (uint256);
    function getEmployee(uint256 employeeId)
        external constant returns (bool    active,
                                   address employee,
                                   uint256 yearlyUSDSalary);

    // @dev Monthly USD amount spent in salaries
    function calculatePayrollBurnrate() external constant returns (uint256);
    // @dev Days until the contract can run out of funds
    function calculatePayrollRunway() external constant returns (uint256);

    /* EMPLOYEE ONLY */
    // @notice Only callable once every 6 months
    function determineAllocation(
        address[] tokens,
        uint256[] distribution
    ) external;

    // @notice Only callable once a month
    function payday() external;

    /* ORACLE ONLY */
    // @dev Uses decimals from token
    function setExchangeRate(address token, uint256 usdExchangeRate) external;

}
