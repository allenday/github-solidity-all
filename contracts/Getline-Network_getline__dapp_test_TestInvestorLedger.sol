pragma solidity ^0.4.11;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/loans/InvestorLedger.sol";
import "../contracts/tokens/PrintableToken.sol";

contract Harness {
    uint256 amountWanted = 10000;
    uint16 interestPermil = 10;
    uint256 printValue = 10000;
    PrintableToken collateralToken = new PrintableToken("collateralToken", 0, "token_symbol", printValue);
    PrintableToken loanToken = new PrintableToken("loanToken", 0, "token_symbol", printValue);
    TestPerson investor = new TestPerson(loanToken, collateralToken);
    TestPerson borrower = new TestPerson(loanToken, collateralToken);
    using InvestorLedger for InvestorLedger.Ledger;
    InvestorLedger.Ledger l;
}

contract TestLedgerCreation is Harness {
    // testLedgerCreation tests wheter a newly created ledger has its
    // parameters set correctly.
    function testLedgerCreation() public {
        l = InvestorLedger.openAccount(collateralToken, loanToken,
            address(borrower), amountWanted, interestPermil,
            3600, 7200);

        Assert.equal(l.collateralToken, collateralToken, "collateralToken should be set");
        Assert.equal(l.loanToken, loanToken, "loanToken should be set");
        Assert.equal(l.borrower, borrower, "borrower should be set");
        Assert.equal(l.amountWanted, amountWanted, "amountWanted should be set");
        Assert.equal(uint(l.interestPermil), uint(interestPermil), "interestPermil should be set");
        Assert.equal(l.receivedCollateral, 0, "receivedCollateral should be zero");
        Assert.equal(l.totalAmountInvested, 0, "amountInvested should be zero");
        Assert.equal(uint(l.state), uint(InvestorLedger.State.CollateralCollection), "Ledger should be in CollateralCollection");
        Assert.equal(uint(l.fundraisingDelta), 3600, "fundraisingDelta should be set");
        Assert.equal(uint(l.paybackDelta), 7200, "paybackDelta should be set");
    }
}

contract TestLedgerPayback is Harness {
    // testLedgerPayback performs a full investment flow and does introspection
    // of the ledger object to check against expected values.
    function testLedgerPayback() public {
        delete l;
        l = InvestorLedger.openAccount(collateralToken, loanToken,
            address(borrower), amountWanted, interestPermil,
            3600, 7200);

        borrower.ensureCollateralBalance(10000);
        borrower.ensureLoanBalance(10000);
        investor.ensureLoanBalance(10000);

        uint256 borrowerCollateralStartBalance = collateralToken.balanceOf(borrower);
        uint256 investorCollateralStartBalance = collateralToken.balanceOf(investor);
        uint256 borrowerLoanStartBalance = loanToken.balanceOf(borrower);
        uint256 investorLoanStartBalance = loanToken.balanceOf(investor);

        // Collect collateral...

        borrower.approveCollateral(this, 2137);
        l.collateralCollectionProcess(borrower);
        Assert.equal(l.receivedCollateral, 2137, "receivedCollateral should be set");
        Assert.equal(uint(l.state), uint(InvestorLedger.State.Fundraising), "Ledger should be in Fundraising");
        Assert.equal(collateralToken.balanceOf(borrower), borrowerCollateralStartBalance - 2137, "borrower should have sent collateral");
        Assert.equal(l.fundraisingDeadline, block.timestamp + 3600, "fundraisingDeadline should be set");

        Assert.equal(l.canWithdrawLoanToken(borrower), 0, "Borrower should not be able to withdraw loan token.");
        Assert.equal(l.canWithdrawCollateralToken(borrower), 0, "Borrower should not be able to withdraw collateral token.");
        Assert.equal(l.canWithdrawLoanToken(investor), 0, "Investor should not be able to withdraw loan token.");
        Assert.equal(l.canWithdrawCollateralToken(investor), 0, "Borrower should not be able to withdraw collateral token.");

        // Send investment in two transfers...

        investor.approveLoan(this, 5000);
        l.fundraisingProcess(investor);
        Assert.equal(uint(l.state), uint(InvestorLedger.State.Fundraising), "Ledger should be in Fundraising");
        Assert.equal(loanToken.balanceOf(investor), investorLoanStartBalance - 5000, "investor should have sent loan");
        Assert.equal(loanToken.balanceOf(this), 5000, "Ledger should have gathered loan");
        Assert.equal(l.totalAmountInvested, 5000, "Ledger should have noted loan");
        Assert.equal(l.amountInvested(investor), 5000, "Ledger should have noted loan");

        investor.approveLoan(this, 6000);
        l.fundraisingProcess(investor);
        Assert.equal(uint(l.state), uint(InvestorLedger.State.Payback), "Ledger should be in Payback");
        Assert.equal(l.totalAmountInvested, 10000, "Ledger should have noted loan");
        Assert.equal(l.amountInvested(investor), 10000, "Ledger should have noted loan");
        Assert.equal(loanToken.balanceOf(investor), investorLoanStartBalance - 10000, "investor should have sent loan");
        Assert.equal(loanToken.balanceOf(this), 0, "Ledger should have sent out loan");
        Assert.equal(loanToken.balanceOf(borrower), borrowerLoanStartBalance + 10000, "borrower should have received loan");
        Assert.equal(l.paybackDeadline, block.timestamp + 7200, "fundraisingDeadline should be set");

        Assert.equal(l.canWithdrawLoanToken(borrower), 0, "Borrower should not be able to withdraw loan token.");
        Assert.equal(l.canWithdrawCollateralToken(borrower), 0, "Borrower should not be able to withdraw collateral token.");
        Assert.equal(l.canWithdrawLoanToken(investor), 0, "Investor should not be able to withdraw loan token.");
        Assert.equal(l.canWithdrawCollateralToken(investor), 0, "Borrower should not be able to withdraw collateral token.");

        // Send payback...

        Assert.equal(l.paybackRequired(), 10100, "Ledger should have calculated correct payback");
        borrower.approveLoan(this, 10100);
        l.paybackProcess(borrower);
        Assert.equal(uint(l.state), uint(InvestorLedger.State.Paidback), "Ledger should be in Paidback");
        Assert.equal(loanToken.balanceOf(borrower), borrowerLoanStartBalance - 100, "Borrower should have sent payback");
        Assert.equal(loanToken.balanceOf(this), 10100, "Ledger should have received payback");

        // Perform withdrawals... 
        uint loanAmount;
        uint collateralAmount;
        loanAmount = l.canWithdrawLoanToken(borrower);
        collateralAmount = l.canWithdrawCollateralToken(borrower);
        Assert.equal(loanAmount, 0, "Borrower should not be able to get loan back");
        Assert.equal(collateralAmount, 2137, "Borrower should be able to get collateral back");
        l.withdraw(borrower);
        Assert.equal(collateralToken.balanceOf(borrower), borrowerCollateralStartBalance, "Borrower collateral should be back to start");

        loanAmount = l.canWithdrawLoanToken(investor);
        collateralAmount = l.canWithdrawCollateralToken(investor);
        Assert.equal(loanAmount, 10100, "Investor should be able to get loan back");
        Assert.equal(collateralAmount, 0, "Investor should not be able to get collateral back");
        l.withdraw(investor);
        Assert.equal(loanToken.balanceOf(investor), investorLoanStartBalance + 100, "Investor loan should be back to start + interest");

        // Perform sanity checks...

        loanAmount = l.canWithdrawLoanToken(borrower);
        collateralAmount = l.canWithdrawCollateralToken(borrower);
        Assert.equal(loanAmount, 0, "There should be no loan withdrawal left for borrower.");
        Assert.equal(collateralAmount, 0, "There should be no colletaral withdrawal left for borrower.");

        loanAmount = l.canWithdrawLoanToken(investor);
        collateralAmount = l.canWithdrawCollateralToken(investor);
        Assert.equal(loanAmount, 0, "There should be no loan withdrawal left for investor.");
        Assert.equal(collateralAmount, 0, "There should be no colletaral withdrawal left for investor.");

        Assert.equal(loanToken.balanceOf(borrower) + loanToken.balanceOf(investor),
                     borrowerLoanStartBalance + investorLoanStartBalance,
                     "Loan token transfers should be zero sum");
        Assert.equal(collateralToken.balanceOf(borrower) + collateralToken.balanceOf(investor),
                     borrowerCollateralStartBalance + investorCollateralStartBalance,
                     "Collateral token transfers should be zero sum");
    }
}

contract TestLedgerZeroCollateral is Harness {
    function testLedgerZeroCollateral() public {
        delete l;
        l = InvestorLedger.openAccount(collateralToken, loanToken,
            address(borrower), amountWanted, interestPermil,
            3600, 7200);

        borrower.ensureCollateralBalance(10000);
        borrower.approveCollateral(this, 0);
        l.collateralCollectionProcess(borrower);
        Assert.equal(uint(l.state), uint(InvestorLedger.State.CollateralCollection), "Ledger should be in CollateralCollection");

        Assert.equal(l.canWithdrawLoanToken(borrower), 0, "Borrower should not be able to withdraw loan token.");
        Assert.equal(l.canWithdrawCollateralToken(borrower), 0, "Borrower should not be able to withdraw collateral token.");
        Assert.equal(l.canWithdrawLoanToken(investor), 0, "Investor should not be able to withdraw loan token.");
        Assert.equal(l.canWithdrawCollateralToken(investor), 0, "Borrower should not be able to withdraw collateral token.");
    }
}

contract TestLedgerUnderPayback is Harness {
    function testLedgerUnderPayback() public {
        delete l;
        l = InvestorLedger.openAccount(collateralToken, loanToken,
            address(borrower), amountWanted, interestPermil,
            3600, 7200);

        borrower.ensureCollateralBalance(10000);
        borrower.ensureLoanBalance(10000);
        investor.ensureLoanBalance(10000);

        borrower.approveCollateral(this, 2137);
        l.collateralCollectionProcess(borrower);
        investor.approveLoan(this, 10000);
        l.fundraisingProcess(investor);

        // Send payback that's too low - this shouldn't accept our tokens and
        // should not advance the state.
        uint256 beforePayback = loanToken.balanceOf(borrower);
        borrower.approveLoan(this, 1337);
        l.paybackProcess(borrower);
        Assert.equal(uint(l.state), uint(InvestorLedger.State.Payback), "Ledger should be in Payback");
        Assert.equal(loanToken.balanceOf(borrower), beforePayback, "Payback should have not been accepted");

        Assert.equal(l.canWithdrawLoanToken(borrower), 0, "Borrower should not be able to withdraw loan token.");
        Assert.equal(l.canWithdrawCollateralToken(borrower), 0, "Borrower should not be able to withdraw collateral token.");
        Assert.equal(l.canWithdrawLoanToken(investor), 0, "Investor should not be able to withdraw loan token.");
        Assert.equal(l.canWithdrawCollateralToken(investor), 0, "Borrower should not be able to withdraw collateral token.");
    }
}

contract TestInvestorLedger {
    TestLedgerCreation tlc = new TestLedgerCreation();
    TestLedgerPayback tlp = new TestLedgerPayback();
    TestLedgerUnderPayback tlup = new TestLedgerUnderPayback();
    TestLedgerZeroCollateral tlzc = new TestLedgerZeroCollateral();

    function testLedgerCreation() public {
        tlc.testLedgerCreation();
    }

    function testLedgerPayback() public {
        tlp.testLedgerPayback();
    }

    function testLedgerUnderPayback() public {
        tlup.testLedgerUnderPayback();
    }

    function testLedgerZeroCollateral() public {
        tlzc.testLedgerZeroCollateral();
    }
}


contract TestPerson {
    PrintableToken loanToken;
    PrintableToken collateralToken;

    function TestPerson(PrintableToken _loanToken, PrintableToken _collateralToken) public {
        loanToken = _loanToken;
        collateralToken = _collateralToken;
    }

    function ensureLoanBalance(uint256 amount) public {
        while (loanToken.balanceOf(this) < amount) {
            loanToken.print(this);
        }
    }

    function ensureCollateralBalance(uint256 amount) public {
        while (collateralToken.balanceOf(this) < amount) {
            collateralToken.print(this);
        }
    }

    function sendCollateral(address target, uint256 amount) public {
        require(collateralToken.transfer(target, amount));
    }

    function sendLoan(address target, uint256 amount) public {
        require(loanToken.transfer(target, amount));
    }

    function approveCollateral(address target, uint256 amount) public {
        require(collateralToken.approve(target, amount));
    }

    function approveLoan(address target, uint256 amount) public {
        require(loanToken.approve(target, amount));
    }
}
