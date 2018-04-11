pragma solidity ^0.4.17;

import "./PaymentServLibrary.sol";
import "./UsingDB.sol";
import "./Gateway.sol";


contract PaymentServ is UsingDB, Gateway {

    using PaymentServLibrary for PaymentServLibrary.Payment;

    PaymentServLibrary.Payment public payment;

    // special value is used to reference ETH => USD exchange rate
    address constant public ETH_SYM_ADDR = 0xeeee;

    event OnEthFundsAdded(address indexed from, uint256 indexed amount);
    event OnPaid(uint256 indexed employeeId, uint256 indexed monthlyUSDSalary);

    function PaymentServ(
        address _db,
        address _ant,
        address _usd,
        address _hatch
    )
        UsingDB(_db)
        public
    {
        payment.setDB(_db);
        payment.setTokens(_ant, _usd, ETH_SYM_ADDR);
        payment.setEscapeHatch(_hatch);
    }

    function calculatePayrollBurnrate()
        external view returns (uint256)
    {
        return payment.calculatePayrollBurnrate();
    }

    function calculatePayrollRunwayInMonths()
        external view returns (uint256)
    {
        return payment.calculatePayrollRunwayInMonths();
    }

    function calculatePayrollRunway()
        external view returns (uint256)
    {
        return payment.calculatePayrollRunway();
    }

    function setDB(address _db)
        onlyOwner
        public
    {
        super.setDB(_db);

        payment.setDB(_db);
    }

    function setTokens(address _ant, address _usd)
        onlyOwner
        external
    {
        payment.setTokens(_ant, _usd, ETH_SYM_ADDR);
    }

    function setEscapeHatch(address _hatch)
        onlyOwner
        external
    {
        payment.setEscapeHatch(_hatch);
    }

    function escapeHatch()
        onlyPayrollOrOwner
        external
    {
        payment.escapeHatch();
    }

    function emergencyWithdraw(address to)
        onlyPayrollOrOwner
        external
    {
        payment.emergencyWithdraw(to);
    }

    function payday(
        uint256 employeeId,
        address account,
        uint256 monthlyUSDSalary
    )
        onlyPayroll
        external
    {
        payment.payday(employeeId, account, monthlyUSDSalary);
    }

    function updateExchangeRates()
        onlyPayrollOrOwner
        external
    {
        payment.updateExchangeRates();
    }

    /// @notice make sure pass msg.sender to 'from' in Payroll contract
    function setExchangeRateByOraclize(address from, bytes32 id, string result)
        onlyPayroll
        external
    {
        payment.setExchangeRateByOraclize(from, id, result);
    }

    function setExchangeRate(address token, uint256 usdExchangeRate)
        onlyPayrollOrOwner
        external
    {
        payment.setExchangeRate(token, usdExchangeRate);
    }

    function addFunds(address from)
        payable
        onlyPayrollOrOwner
        external
    {
        OnEthFundsAdded(from, msg.value);
    }

    function ()
        payable
        external
    {
        revert();
    }

}
