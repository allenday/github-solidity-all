pragma solidity ^0.4.17;

import "./PayrollDB.sol";
import "./HashLibrary.sol";
import "./EscapeHatch.sol";
import "./SharedLibrary.sol";

import "./oraclizeAPI.lib.sol";
import "zeppelin-solidity/contracts/token/ERC20.sol";
import "zeppelin-solidity/contracts/math/SafeMath.sol";


library PaymentServLibrary {

    using SafeMath for uint256;

    struct Payment {
        // PayrollDB
        address db;
        // USD token
        address usdToken;
        // ANT token
        address antToken;
        // special value reference to ETH => USD exchange rate
        address eth;
        address hatch;

        uint256 nextPayDay;
        uint256 payRound;

        // payRound => amount
        mapping (uint256 => uint256) unpaidUSDSalaries;
        // exchange rates
        // x USD to 1 ANT
        // x USD to 1 ETH (ETH use 0xeth special address)
        // 1 USD to 1 USD
        mapping (address => uint256) exchangeRates;
        // payRound => (account => isPaid)
        mapping (uint256 => mapping (address => bool)) payStats;
        mapping (bytes32 => uint256) isOracleId;
    }

    event OnPaid(uint256 indexed employeeId, uint256 indexed monthlyUSDSalary);

    /// @dev Calculate Monthly USD amount spent in salaries
    /// @param self Payment Payment struct
    /// @return uint256 total monthly USD salaries
    function calculatePayrollBurnrate(Payment storage self)
        internal view returns (uint256)
    {
        return PayrollDB(self.db).getUIntValue(
            HashLibrary.hash("/USDMonthlySalaries")
        );
    }

    /// @dev Calculate months until the contract run out of funds
    /// @notice We assume the pay day is same for all employees
    /// @param self Payment Payment data struct
    /// @return uint256 left months
    function calculatePayrollRunwayInMonths(Payment storage self)
        internal view returns (uint256)
    {
        uint256 unpaidUSDSalaries = self.unpaidUSDSalaries[self.payRound];
        uint256 usdFunds = ERC20(self.usdToken).balanceOf(this);

        // ANT token (x USD to 1 ANT)
        uint256 antExchangeRate = self.exchangeRates[self.antToken];
        uint256 antFunds = ERC20(self.antToken).balanceOf(this);
        // antFunds * antExchangeRate
        usdFunds = usdFunds.add(antFunds.mul(antExchangeRate));

        // ETH (x USD to 1 ETH)
        uint256 ethExchangeRate = self.exchangeRates[self.eth];
        // ethFunds * ethExchangeRate
        usdFunds = usdFunds.add(this.balance.mul(ethExchangeRate));

        usdFunds = usdFunds.sub(unpaidUSDSalaries);
        uint256 usdMonthlySalaries = calculatePayrollBurnrate(self);
        // usdFunds / sudMonthlySalaries
        return usdFunds.div(usdMonthlySalaries);
    }

    /// @dev Calculate days until the contract run out of funds
    /// @notice We assume the pay day is same for all employees
    /// @param self Payment Payment data struct
    /// @return uint256 left days
    function calculatePayrollRunway(Payment storage self)
        internal view returns (uint256)
    {
        uint256 ONE_MONTH = 4 weeks;
        uint256 date = self.nextPayDay;
        uint256 leftMonths = calculatePayrollRunwayInMonths(self);

        if (date == 0) {
            // nothing paid yet
            date = now;
        } else {
            // calculate from previous payday
            date = date.sub(ONE_MONTH);
        }
        return date.add(leftMonths.mul(ONE_MONTH));
    }

    /// @dev Get all allowed tokens for givem employeId
    /// @param self Payment Payment struct
    /// @param employeeId uint256 given id to query
    /// @return address[] allowed tokens
    function getEmployeeTokens(Payment storage self, uint256 employeeId)
        internal view returns (address[] tokens)
    {
        PayrollDB db = PayrollDB(self.db);
        uint256 count = db.getUIntValue(
            HashLibrary.hash("/tokens/count", employeeId)
        );
        uint256 nonce = db.getUIntValue(
            HashLibrary.hash("/tokens/nonce", employeeId)
        );
        tokens = new address[](count);

        for (uint i = 0; i < tokens.length; i++) {
            tokens[i] = db.getAddressValue(
                HashLibrary.hash(
                    "/tokens",
                    employeeId,
                    nonce,
                    i
                )
            );
        }

        return tokens;
    }

    /// @dev Get tokens allocation for given employeeId
    /// @param self Payment Payment struct
    /// @param employeeId uint256 given id to query
    /// @return uint256[] tokens allocation
    function getEmployeeTokensAlloc(Payment storage self, uint256 employeeId)
        internal view returns (uint256[] allocation)
    {
        PayrollDB db = PayrollDB(self.db);
        uint256 nonce = db.getUIntValue(
            HashLibrary.hash("/tokens/alloc/nonce", employeeId)
        );
        var tokens = getEmployeeTokens(self, employeeId);
        allocation = new uint256[](tokens.length);

        for (uint i = 0; i < tokens.length; i++) {
            allocation[i] = db.getUIntValue(
                HashLibrary.hash(
                    "/tokens/alloc",
                    employeeId,
                    nonce,
                    tokens[i]
                )
            );
        }

        return allocation;
    }

    /// @dev Set PayrollDB address
    /// @param self Payment Payment data struct
    /// @param _db address Deployed PayrollDB address
    function setDB(Payment storage self, address _db)
        internal
    {
        require(_db != 0x0);

        self.db = _db;
    }

    /// @dev Set ANT token and USD token addresses
    /// @param self Payment Payment data struct
    /// @param _ant address Deployed ANT token address
    /// @param _usd address Deployed USD token address
    /// @param _eth address special value reference ETH => USD exchange rate
    function setTokens(
        Payment storage self,
        address _ant,
        address _usd,
        address _eth
    )
        internal
    {
        require(_ant != 0x0 && _usd != 0x0);

        self.antToken = _ant;
        self.usdToken = _usd;
        self.eth = _eth;

        // set up default rate to 1 USD to 1 USD for usdToken
        setExchangeRate(self, _usd, 1);
    }

    /// @dev Set escape hatch address
    /// @param self Payment Payment data struct
    /// @param _hatch address Deployed escape hatch contract address
    function setEscapeHatch(Payment storage self, address _hatch)
        internal
    {
        require(_hatch != 0x0);

        self.hatch = _hatch;
    }

    /// @dev Pause escape hatch contract
    /// @param self Payment Payment data struct
    function escapeHatch(Payment storage self)
        internal
    {
        EscapeHatch(self.hatch).pausePayment();
    }

    /// @dev Pay salary to employee
    /// @notice We assume all employees take their salaries every months. Also
    /// employee can only call this function once per month.
    /// @param self Payment Payment data struct
    /// @param employeeId uint256 employee id
    /// @param account address employee account
    /// @param monthlyUSDSalary uint256 monthly USD salary
    function payday(
        Payment storage self,
        uint256 employeeId,
        address account,
        uint256 monthlyUSDSalary
    )
        internal
    {
        uint ONE_MONTH = 4 weeks;
        uint payRound = self.payRound;
        uint nextPayDay = self.nextPayDay;
        uint unpaidUSDSalaries = self.unpaidUSDSalaries[payRound];

        if (now > nextPayDay) {
            // start next pay round
            uint256 usdMonthlySalaries = calculatePayrollBurnrate(self);
            payRound = payRound.add(1);
            self.unpaidUSDSalaries[payRound] = unpaidUSDSalaries.add(
                usdMonthlySalaries
            );

            self.payRound = payRound;
            if (nextPayDay == 0) {
                // this is first payment
                nextPayDay = now;
            }
            self.nextPayDay = nextPayDay.add(ONE_MONTH);
        }

        if (self.payStats[payRound][account]) {
            revert();
        }
        self.payStats[payRound][account] = true;

        pay(
            self,
            employeeId,
            account,
            monthlyUSDSalary
        );
    }

    /// @dev Withdraw all token and eth
    /// @param self Payment Payment data struct
    /// @param to address where we send ETH and tokens
    function emergencyWithdraw(Payment storage self, address to)
        internal
    {
        address[] memory tokens = new address[](2);
        tokens[0] = self.antToken;
        tokens[1] = self.usdToken;
        SharedLibrary.withdrawFrom(this, to, tokens);
    }

    /// @dev Use oraclize oracle to fetch latest token exchange rates
    /// @param self Payment Payment data struct
    function updateExchangeRates(Payment storage self)
        internal
    {
        uint delay = 10;
        string memory ANT_TO_USD = "json(https://min-api.cryptocompare.com/data/price?fsym=ANT&tsyms=USD).USD";
        string memory ETH_TO_USD = "json(https://min-api.cryptocompare.com/data/price?fsym=ETH&tsyms=USD).USD";

        bytes32 antId = oraclizeLib.oraclize_query(delay, "URL", ANT_TO_USD);
        bytes32 ethId = oraclizeLib.oraclize_query(delay, "URL", ETH_TO_USD);

        self.isOracleId[antId] = 1;
        self.isOracleId[ethId] = 2;
    }

    /// @dev Callback function used by oraclize to actually set token exchange
    /// rate.
    /// @param self Payment Payment data struct
    /// @param from address where this data comes from
    /// @param id bytes32 oraclize generated id per querying
    /// @param result string oraclize querying result, toke exchange rate
    function setExchangeRateByOraclize(
        Payment storage self,
        address from,
        bytes32 id,
        string result
    )
        internal
    {
        require(from == oraclizeLib.oraclize_cbAddress());
        require(self.isOracleId[id] > 0 && self.isOracleId[id] < 3);

        uint256 rate = oraclizeLib.parseInt(result, 2);
        if (self.isOracleId[id] == 1) {
            setExchangeRate(self, self.antToken, rate);
        } else if (self.isOracleId[id] == 2) {
            setExchangeRate(self, self.eth, rate);
        }
    }

    /// @dev Set token exchange rate
    /// @param self Payment Payment data struct
    /// @param token address target token
    /// @param usdExchangeRate uint256 exchange rate
    function setExchangeRate(
        Payment storage self,
        address token,
        uint256 usdExchangeRate
    )
        internal
    {
        require(usdExchangeRate > 0);

        self.exchangeRates[token] = usdExchangeRate;
    }

    /// @dev Pay to employee
    /// @param self Payment Payment data struct
    /// @param employeeId uint256 employee id
    /// @param account address employee account
    /// @param monthlyUSDSalary uint256 monthly USD salary
    function pay(
        Payment storage self,
        uint256 employeeId,
        address account,
        uint256 monthlyUSDSalary
    )
        private
    {
        var tokens = getEmployeeTokens(self, employeeId);
        var tokensAllocation = getEmployeeTokensAlloc(self, employeeId);
        uint256 payRound = self.payRound;

        self.unpaidUSDSalaries[payRound] = self.unpaidUSDSalaries[payRound].sub(
            monthlyUSDSalary
        );

        uint256 leftUSDSalary = payInToken(
            self,
            account,
            monthlyUSDSalary,
            tokens,
            tokensAllocation
        );

        // handle left ether
        uint ethAmount = 0;
        if (leftUSDSalary > 0) {
            // x USD to 1 ether
            uint ethExchangeRate = self.exchangeRates[self.eth];
            // leftUSDSalary / ethExchangeRate
            ethAmount = leftUSDSalary.div(ethExchangeRate);
            EscapeHatch(self.hatch).quarantine.value(ethAmount)(
                account,
                new address[](0),
                new uint256[](0)
            );
        }

        OnPaid(employeeId, monthlyUSDSalary);
    }

    /// @dev Pay to employee
    /// @param self Payment Payment data struct
    /// @param account address employee account address
    /// @param monthlyUSDSalary uint256 monthly usd salary
    /// @param tokens address[] allowed tokens
    /// @param allocation uint256[] tokens allocation
    /// @return uint256 left unpaid usd salary
    function payInToken(
        Payment storage self,
        address account,
        uint256 monthlyUSDSalary,
        address[] tokens,
        uint256[] allocation
    )
        private returns (uint256)
    {
        uint256 leftUSDSalary = monthlyUSDSalary;
        uint256[] memory payAmounts = new uint256[](tokens.length);

        for (uint i = 0; i < tokens.length; i++) {
            if (leftUSDSalary == 0) {
                break;
            }
            if (allocation[i] == 0) {
                continue;
            }

            // monthlyUSDSalary * allocation / 100
            uint usdAmount = monthlyUSDSalary.mul(allocation[i]).div(100);
            leftUSDSalary = leftUSDSalary.sub(usdAmount);

            // XXX token (x USD to 1 XXX)
            uint exRate = self.exchangeRates[tokens[i]];
            // usdAmount / exRate
            uint tAmount = usdAmount.div(exRate);
            payAmounts[i] = tAmount;
            ERC20(tokens[i]).transfer(self.hatch, tAmount);
        }

        EscapeHatch(self.hatch).quarantine(account, tokens, payAmounts);
        return leftUSDSalary;
    }

}
