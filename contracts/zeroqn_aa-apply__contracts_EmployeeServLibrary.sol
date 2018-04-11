pragma solidity ^0.4.17;

/**
 * @title EmployeeServLibrary
 * @dev This library implement most of logic for Employee contract
 */

import "./PayrollDB.sol";
import "./HashLibrary.sol";

import "zeppelin-solidity/contracts/math/SafeMath.sol";


library EmployeeServLibrary {

    using SafeMath for uint256;

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

    /// @dev Check if given address has account and is active employee
    /// @param _db address Deployed PayrollDB address
    /// @return bool true if given address has corresponding active account
    function isEmployee(address _db, address account)
        internal view returns (bool)
    {
        PayrollDB db = PayrollDB(_db);

        uint256 employeeId = db.getUIntValue(
            HashLibrary.hash("/id", account)
        );
        if (employeeId == 0) {
            return false;
        }

        // isn't active
        if (!db.getBooleanValue(HashLibrary.hash("/active", employeeId))) {
            return false;
        }

        return true;
    }

    /// @dev Get active employee count
    /// @param db address Deployed PayrollDB address
    /// @return uint256 active employee count
    function getEmployeeCount(address db)
        internal view returns (uint256)
    {
        return PayrollDB(db).getUIntValue(HashLibrary.hash("/count"));
    }

    /// @dev Get employeeId for given address
    /// @param db address Deployed PayrollDB address
    /// @param account address given address to query
    /// @return uint256 employeeId
    function getEmployeeId(address db, address account)
        internal view returns (uint256)
    {
        return PayrollDB(db).getUIntValue(HashLibrary.hash("/id", account));
    }

    /// @dev Get employee info for given id
    /// @param _db address Deployed PayrollDB address
    /// @param employeeId uint256 given employeeId to query
    /// @return bool if employee is active
    /// @return address given employee account
    /// @return uint256 monthly USD salary
    /// @return uint256 yearly USD salary
    function getEmployee(address _db, uint256 employeeId)
        internal view returns (bool    active,
                                   address account,
                                   uint256 monthlyUSDSalary,
                                   uint256 yearlyUSDSalary)
    {
        PayrollDB db = PayrollDB(_db);

        active = db.getBooleanValue(HashLibrary.hash("/active", employeeId));
        account = db.getAddressValue(HashLibrary.hash("/account", employeeId));
        monthlyUSDSalary = db.getUIntValue(
            HashLibrary.hash("/monthlyUSDSalary", employeeId)
        );
        yearlyUSDSalary = db.getUIntValue(
            HashLibrary.hash("/yearlyUSDSalary", employeeId)
        );

        return (active, account, monthlyUSDSalary, yearlyUSDSalary);
    }

    /// @dev Add new employee
    /// @param _db address Deployed PayrollDB address
    /// @param account address employee address
    /// @param allowedTokens address[] allowed tokens for salary payment
    /// @param initialYearlyUSDSalary uint256 salary in USD for year
    /// @return uint256 employee id
    function addEmployee(
        address   _db,
        address   account,
        address[] allowedTokens,
        uint256   initialYearlyUSDSalary
    )
        internal returns (uint256)
    {
        require(account != 0x0);
        require(initialYearlyUSDSalary > 0);
        for (uint i = 0; i < allowedTokens.length; i++) {
            require(allowedTokens[i] != 0x0);
        }

        PayrollDB db = PayrollDB(_db);


        uint256 id = nextId(db);
        db.addUIntValue(HashLibrary.hash("/count"), 1);
        db.setBooleanValue(HashLibrary.hash("/active", id), true);
        db.setAddressValue(HashLibrary.hash("/account", id), account);
        setAllowedTokens(db, id, allowedTokens);
        db.setUIntValue(
            HashLibrary.hash("/yearlyUSDSalary", id), initialYearlyUSDSalary
        );
        updateUSDMonthlySalaries(db, id, initialYearlyUSDSalary);
        db.setUIntValue(HashLibrary.hash("/id", account), id);
        OnEmployeeAdded(id, account, initialYearlyUSDSalary);

        return id;
    }

    /// @dev Set employee yearly salary
    /// @param db address Deployed PayrollDB address
    /// @param employeeId uint256 give id to query
    /// @param yearlyUSDSalary uint256 salary in USD for year
    function setEmployeeSalary(
        address db,
        uint256 employeeId,
        uint256 yearlyUSDSalary
    )
        internal
    {
        require(employeeId > 0);
        require(yearlyUSDSalary > 0);

        updateUSDMonthlySalaries(db, employeeId, yearlyUSDSalary);
        PayrollDB(db).setUIntValue(
            HashLibrary.hash("/yearlyUSDSalary", employeeId), yearlyUSDSalary
        );
        OnEmployeeSalaryUpdated(employeeId, yearlyUSDSalary);
    }

    /// @dev Remove employee
    /// @param _db address Deployed PayrollDB address
    /// @param employeeId uint256 given id to remove
    function removeEmployee(address _db, uint256 employeeId)
        internal
    {
        require(employeeId > 0);
        PayrollDB db = PayrollDB(_db);

        db.setBooleanValue(HashLibrary.hash("/active", employeeId), false);
        db.subUIntValue(HashLibrary.hash("/count"), 1);
        OnEmployeeRemoved(employeeId);
    }

    /// @dev Set employee allowed tokens allocation
    /// @param _db address Deployed PayrollDB address
    /// @param tokens address[] allowed tokens
    /// @param distribution uint256[] tokens allocation
    function setEmployeeTokenAllocation(
        address   _db,
        address   account,
        address[] tokens,
        uint256[] distribution
    )
        internal
    {
        uint256 SIX_MONTHS = 4 weeks * 6;

        PayrollDB db = PayrollDB(_db);
        uint256 distSum = 0;
        uint256 employeeId = db.getUIntValue(
            HashLibrary.hash("/id", account)
        );
        uint256 nonce = db.getUIntValue(
            HashLibrary.hash("/tokens/nonce", employeeId)
        );
        uint256 nextAllocTime = db.getUIntValue(
            HashLibrary.hash("/tokens/nextAllocTime", employeeId)
        );

        require(now > nextAllocTime);
        require(tokens.length == distribution.length);
        for (uint i = 0; i < tokens.length; i++) {
            // token should be listed
            require(
                db.getBooleanValue(
                    HashLibrary.hash(
                        "/tokens",
                        employeeId,
                        nonce,
                        tokens[i]
                    )
                )
            );
            // single dist should not exceed 100
            require(distribution[i] <= 100);
            distSum = distSum.add(distribution[i]);
        }
        require(distSum <= 100);

        // update next allocation time
        if (nextAllocTime == 0) {
            // first time
            nextAllocTime = now;
        }
        nextAllocTime = nextAllocTime.add(SIX_MONTHS);
        db.setUIntValue(
            HashLibrary.hash("/tokens/nextAllocTime", employeeId),
            nextAllocTime
        );

        setTokensAllocation(
            _db,
            employeeId,
            tokens,
            distribution
        );
    }

    function nextId(address db)
        private returns (uint256)
    {
        return PayrollDB(db).addUIntValue(HashLibrary.hash("/idCount"), 1);
    }

    function setAllowedTokens(
        address   _db,
        uint256   employeeId,
        address[] tokens
    )
        private
    {
        PayrollDB db = PayrollDB(_db);
        // also update nonce
        uint256 nonce = db.addUIntValue(
            HashLibrary.hash("/tokens/nonce", employeeId), 1
        );

        db.setUIntValue(
            HashLibrary.hash("/tokens/count", employeeId), tokens.length
        );
        for (uint i = 0; i < tokens.length; i++) {
            db.setAddressValue(
                HashLibrary.hash(
                    "/tokens",
                    employeeId,
                    nonce,
                    i
                ),
                tokens[i]
            );
            db.setBooleanValue(
                HashLibrary.hash(
                    "/tokens",
                    employeeId,
                    nonce,
                    tokens[i]
                ),
                true
            );
        }
    }

    function setTokensAllocation(
        address   _db,
        uint256   employeeId,
        address[] tokens,
        uint256[] distribution
    )
        private
    {
        PayrollDB db = PayrollDB(_db);

        // also update nonce
        uint256 nonce = db.addUIntValue(
            HashLibrary.hash("/tokens/alloc/nonce", employeeId), 1
        );
        for (uint i = 0; i < tokens.length; i++) {
            db.setUIntValue(
                HashLibrary.hash(
                    "/tokens/alloc",
                    employeeId,
                    nonce,
                    tokens[i]
                ),
                distribution[i]
            );
            OnAllocationChanged(employeeId, tokens[i], distribution[i]);
        }
    }

    function updateUSDMonthlySalaries(
        address _db,
        uint256 employeeId,
        uint256 yearlyUSDSalary
    )
        private
    {
        require(yearlyUSDSalary % 12 == 0);

        PayrollDB db = PayrollDB(_db);

        uint256 usdMonthlySalaries = db.getUIntValue(
            HashLibrary.hash("/USDMonthlySalaries")
        );
        uint256 monthlyUSDSalary = yearlyUSDSalary.div(12);

        // for exist employee, subtract previous monthly salary
        // then add updated one.
        uint256 preMonthlySalary = db.getUIntValue(
            HashLibrary.hash("/monthlyUSDSalary", employeeId)
        );
        if (preMonthlySalary != 0) {
            usdMonthlySalaries = usdMonthlySalaries.sub(preMonthlySalary);
        }

        usdMonthlySalaries = usdMonthlySalaries.add(monthlyUSDSalary);
        db.setUIntValue(
            HashLibrary.hash("/USDMonthlySalaries"), usdMonthlySalaries
        );
        db.setUIntValue(
            HashLibrary.hash("/monthlyUSDSalary", employeeId), monthlyUSDSalary
        );
    }

}
