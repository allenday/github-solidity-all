pragma solidity ^0.4.17;

import "../tokens/IToken.sol";
import "../common/Math.sol";


library InvestorLedger {
    /// Events

    // A state transition in the loan FSM occured.
    event StateTransition(
        address indexed loan,
        State from,
        State to
    );

    // A new investor has invested.
    event NewInvestor(
        address indexed loan,
        address indexed investor
    );

    // An investment has been sent.
    event InvestmentSent(
        address indexed loan,
        address indexed investor,
        uint256 amount
    );

    enum WithdrawalType {
        Invalid,
        // Address has withdrawn loan tokens.
        LoanTokens,
        // Address has withdrawn collateral tokens.
        CollateralTokens
    }

    // An address has withdrawn funds.
    event Withdrawal(
        address indexed loan,
        address indexed to,
        WithdrawalType withdrawalType,
        uint256 amount
    );

    uint constant PERMIL = 1000;

    enum State {
        // Loan is waiting for collateral to be received from borrower.
        CollateralCollection,
        // Loan is waiting to be funded by investors.
        Fundraising,
        // Loan is waiting for withdrawal from borrower.
        Payback,
        // Loan has been paid back succesfully.
        Paidback,
        // Loan has defaulted before it has been fully paid back.
        Defaulted,
        // Loan has been cancelled by borrower or has not gathered funds in
        // time.
        Canceled
    }

    // legalTransition is a safeguard function to be used in functions that
    // modify the Ledger state. It is not checked when the state does not
    // change (so all A -> A transitions are implicitly allowed).
    function legalTransition(State from, State to) pure private returns (bool legal) {
        // No switch statements in Solidity. We'll use a bunch of if-else
        // blocks, as the alternative is handcrafted assembly.
        if (from == State.CollateralCollection) {
            // Loan has collected collateral.
            if (to == State.Fundraising) {
                return true;
            }
            return false;
        }
        if (from == State.Fundraising) {
            // Loan has raised funds succesfully.
            if (to == State.Payback) {
                return true;
            }
            // Loan has not raised funds succesfully - let borrower and
            // investors (if any) collect their tokens back.
            if (to == State.Canceled) {
                return true;
            }
            return false;
        }
        if (from == State.Payback) {
            // Loan has been paid back successfully.
            if (to == State.Paidback) {
                return true;
            }
            // Loan has defaulted.
            if (to == State.Defaulted) {
                return true;
            }
            return false;
        }
        return false;
    }

    // newState applies a state transition to the ledger FSM and ensures it is
    // legal.
    function newState(Ledger storage ledger, State next) private {
        require(legalTransition(ledger.state, next));
        StateTransition(this, ledger.state, next);
        ledger.state = next;
    }

    // Ledger is the main state object of an ongoing loan ledger.
    struct Ledger {
        /// Constant ledger parameters.
        // Token used as collateral.
        IToken collateralToken;
        // Main loan Token.
        IToken loanToken;
        // Receiver of the loan.
        address borrower;
        // How much loanToken does borrower want to borrow.
        uint256 amountWanted;
        // Interest of loan in permils.
        uint16  interestPermil;
        // Delta (in seconds) between collateral collected and fundraising ending.
        uint64 fundraisingDelta;
        // Delta (in seconds)  between fundraising ending and payback needed.
        uint64 paybackDelta;

        /// Mutable ledger state.
        // Total collateralToken gathered for loan. It increases from 0 to
        // the loan collateral when its' gathered.
        uint256 receivedCollateral;
        // Data about each investor. It gets upserted any time a new investment
        // is added.
        mapping(address => InvestorData) investorData;
        // Sum of all investments, updated when investorData is updated.
        uint256 totalAmountInvested;
        // Absolute timestamp of fundraising deadline, in block time (seconds).
        // Calculated when we switch to the fundraising state.
        uint64 fundraisingDeadline;
        // Absolute timestamp of payback deadline, in block time (seconds).
        // Calculated when we switch to the payback state.
        uint64 paybackDeadline;

        /// Withdrawal counters. These increase as different types of withdrawals
        /// are performed.
        mapping(address => WithdrawalData) withdrawalData;

        /// Main ledger FSM state.
        State state;
    }

    struct InvestorData {
        uint256 amountInvested;
    }

    struct WithdrawalData {
        uint256 loanWithdrawn;
        uint256 collateralWithdrawn;
    }

    /// View functions for the Ledger structure that calculate denormalized
    /// data based on investment status.
    
    // amountInvested(address) returns how much was invested into this loan by
    // a particular address.
    function amountInvested(Ledger storage ledger, address investor) view public returns (uint256 amount) {
        return ledger.investorData[investor].amountInvested;
    }

    // paybackRequired returns how much payback is/will be required for this
    // loan (loan amount + interest).
    function paybackRequired(Ledger storage ledger) view public returns (uint256 amount) {
        return ledger.amountWanted + calculateInterest(ledger, ledger.amountWanted);
    }

    // calculateInterest is a convenience function to calculate the interest
    // of this loan on a given value.
    function calculateInterest(Ledger storage ledger, uint256 investment) view private returns (uint256 interest) {
        return investment * ledger.interestPermil / PERMIL;
    }

    // currentState returns the ledger's current state, possible altered by
    // timeouts.
    function currentState(Ledger storage ledger) processTimeouts(ledger) public returns (State state) {
        return ledger.state;
    }

    // openAccount is a static constructor of the Ledger state object.
    // @param collateralToken: Token to be used as collateral during the loan.
    // @param loanToken: Token to be loaned.
    // @param borrower: Receiver of the loan.
    // @param totalLoanNeded: How much loanToken does borrower want to borrow.
    // @param interestPermil: Loan interest, in permil (1/10th of a percent).
    function openAccount(
        IToken collateralToken,
        IToken loanToken,
        address borrower,
        uint256 amountWanted,
        uint16 interestPermil,
        uint64 fundraisingDelta,
        uint64 paybackDelta) internal view returns (Ledger account)
    {
        // Argument validation.
        require(fundraisingDelta > 0);
        require(paybackDelta > 0);
        require(amountWanted > 0);

        /// Overflow checks for time deltas. These are overkill as we only
        /// accept 64-bit arguments for deltas yet store timestamps in 256-bit
        /// variables.
        // Ensure that a calculated fundraising time does not overflow to be
        // before now.
        require(block.timestamp + fundraisingDelta > block.timestamp);
        // Ensure that a calculated payback time does not overflow to be
        // before now.
        require(block.timestamp + fundraisingDelta + paybackDelta > block.timestamp);
        // Ensure that a calculated payback time does not overflow to be before
        // fundraising.
        require(block.timestamp + fundraisingDelta + paybackDelta > block.timestamp + fundraisingDelta);

        // Fill new state object.
        account.collateralToken = collateralToken;
        account.loanToken = loanToken;
        account.amountWanted = amountWanted;
        account.interestPermil = interestPermil;
        account.borrower = borrower;
        account.state = State.CollateralCollection;
        account.fundraisingDelta = fundraisingDelta;
        account.paybackDelta = paybackDelta;
        account.fundraisingDeadline = 0;
        account.paybackDeadline = 0;

        // And return it.
        return account;
    }

    // Checks if the current ledger state is one that can time out. If so,
    // performs the timeout check and advances state if required.
    modifier processTimeouts(Ledger storage ledger) {
        if (ledger.state == State.Fundraising) {
            if (block.timestamp > ledger.fundraisingDeadline) {
                newState(ledger, State.Canceled);
            }
        }

        if (ledger.state == State.Payback) {
            if (block.timestamp > ledger.paybackDeadline) {
                newState(ledger, State.Defaulted);
            }
        }

        _;
    }

    // collateralCollectionProcess performs processing within the
    // CollateralCollection state of the loan FSM and possibly advances to its'
    // next state. It can:
    //  - collect the collateral from the borrower and mark the loan as
    //    Fundraising (the loan now has a collateral it needs to send back)
    function collateralCollectionProcess(Ledger storage ledger, address caller) public {
        require(ledger.state == State.CollateralCollection);
        // Only allow borrower to perform the state transition, otherwise we
        // could permit races where a malicious actor performs the state
        // transition when the borrower is not ready to do so.
        require(caller == ledger.borrower);

        var allowance = ledger.collateralToken.allowance(ledger.borrower, this);
        if (allowance > 0) {
            newState(ledger, State.Fundraising);
            uint64 timestamp = uint64(block.timestamp);
            ledger.receivedCollateral += allowance;
            ledger.fundraisingDeadline = timestamp + ledger.fundraisingDelta;
            require(ledger.fundraisingDeadline > timestamp);
            require(ledger.fundraisingDeadline + ledger.paybackDelta > ledger.fundraisingDeadline);

            require(
                ledger.collateralToken.transferFrom(
                    ledger.borrower,
                    this,
                    allowance
                )
            );
        }
    }

    // fundraisingProcess performs processing within the Fundraising state of
    // the loan FSM and possibly advances to its' next state. It can:
    // - collect funds from an investor and mark them in a mapping
    // - if loan is fully funded, send out the investments to the borrower and
    //   advance to the Payback state
    // - if timeout is reached, advance to the Canceled state
    function fundraisingProcess(Ledger storage ledger, address caller) processTimeouts(ledger) public {
        require(ledger.state == State.Fundraising);

        uint256 amountNeeded = ledger.amountWanted - ledger.totalAmountInvested;
        address investor = caller;
        // Do not invest more than required to fullfill amountWanted.
        var investmentAmount = Math.min(
            ledger.loanToken.allowance(investor, this),
            amountNeeded
        );
        if (investmentAmount > 0) {
            uint64 timestamp = uint64(block.timestamp);
            var investorData = ledger.investorData[investor];
            if (investorData.amountInvested == 0) {
                NewInvestor(this, investor);
            }

            // Check overflows on investment amounts.
            require(investorData.amountInvested + investmentAmount > investorData.amountInvested);
            require(ledger.totalAmountInvested + investmentAmount > ledger.totalAmountInvested);
            // Did we just gather all investments required? Change state and
            // block re-entry to this state.
            if (ledger.totalAmountInvested + investmentAmount == ledger.amountWanted) {
                newState(ledger, State.Payback);
                ledger.paybackDeadline = timestamp + ledger.paybackDelta;
            }
            // Note down the investment.
            investorData.amountInvested += investmentAmount;
            ledger.totalAmountInvested += investmentAmount;

            // Transfer the investment to the receiving contract.
            InvestmentSent(this, investor, investmentAmount);
            require(
                ledger.loanToken.transferFrom(
                    investor,
                    this,
                    investmentAmount
                )
            );
            // If this was the last required invesment, transfer all the
            // invested money to the borrower.
            if (ledger.totalAmountInvested == ledger.amountWanted) {
                require(
                    ledger.loanToken.transfer(
                        ledger.borrower,
                        ledger.amountWanted
                    )
                );
            }
        }
    }

    // paybackProcess prforms processing within the Payback state of the loan
    // FSM and possibly advances to its' next state. It can:
    // - collect a full payback from the borrower and advance to the Paidback
    //   state
    // - if timeout is reached, advance to the Paidback state
    function paybackProcess(Ledger storage ledger, address caller) processTimeouts(ledger) public {
        require(ledger.state == State.Payback);

        if (caller != ledger.borrower) {
            return;
        }

        // Gather payback, if possible.
        uint256 payback = paybackRequired(ledger);
        if (ledger.loanToken.allowance(ledger.borrower, this) >= payback) {
            newState(ledger, State.Paidback);
            require(
                ledger.loanToken.transferFrom(
                    ledger.borrower,
                    this,
                    payback
                )
            );
        }
    }

    // canWithdrawLoanToken performs processing to see if a given address can
    // withdraw loan tokens in one of the final states (Paidback, Canceled,
    // Defaulted)
    function canWithdrawLoanToken(Ledger storage ledger, address caller) processTimeouts(ledger) public returns (uint256 _amount) {
        if (ledger.state == State.Paidback) {
            // In Paidback, investors can withdraw investment with interest.
            uint256 invested = ledger.investorData[caller].amountInvested;
            invested += calculateInterest(ledger, invested);
            uint256 withdrawn = ledger.withdrawalData[caller].loanWithdrawn;
            return invested - withdrawn;
        }

        if (ledger.state == State.Canceled) {
            // If the loan was canceled before investment was finished,
            // investors can get their investment back without interest.
            invested = ledger.investorData[caller].amountInvested;
            withdrawn = ledger.withdrawalData[caller].loanWithdrawn;
            return invested - withdrawn;
        }

        return 0;
    }

    // canWithdrawCollateralToken performs processing to see if a given address
    // can withdraw collateral tokens in one of the final states (Paidback,
    // Canceled, Defaulted)
    function canWithdrawCollateralToken(Ledger storage ledger, address caller) processTimeouts(ledger) public returns (uint256 _amount) {

        if (ledger.state == State.Paidback && caller == ledger.borrower) {
            // In Paidback, the borrower can withdraw their collateral fully.
            uint256 collected = ledger.receivedCollateral;
            uint256 withdrawn = ledger.withdrawalData[caller].collateralWithdrawn;
            return collected - withdrawn;
        }
        if (ledger.state == State.Canceled && caller == ledger.borrower) {
            // In Canceled, the borrower can withdraw their collateral fully.
            collected = ledger.receivedCollateral;
            withdrawn = ledger.withdrawalData[caller].collateralWithdrawn;
            return collected - withdrawn;
        }
        if (ledger.state == State.Defaulted) {
            // In defaulted, investors can withdraw the collateral prorated by
            // their investment.
            collected = ledger.receivedCollateral;
            uint256 invested = ledger.investorData[caller].amountInvested;
            uint256 totalInvested = ledger.totalAmountInvested;
            uint256 share = invested * collected / totalInvested;
            withdrawn = ledger.withdrawalData[caller].collateralWithdrawn;
            return share - withdrawn;
        }

        return 0;
    }

    // withdraw performs withdrawal to a given address of a loan or collateral
    // token (whichever is available).
    function withdraw(Ledger storage ledger, address caller) public {
        uint256 loan = canWithdrawLoanToken(ledger, caller);
        if (loan > 0) {
            ledger.withdrawalData[caller].loanWithdrawn += loan;
            Withdrawal(
                this,
                caller,
                WithdrawalType.LoanTokens,
                loan
            );
            require(
                ledger.loanToken.transfer(
                    caller,
                    loan
                )
            );
            return;
        }
        uint256 collateral = canWithdrawCollateralToken(ledger, caller);
        if (collateral > 0) {
            ledger.withdrawalData[caller].collateralWithdrawn += collateral;
            Withdrawal(
                this,
                caller,
                WithdrawalType.CollateralTokens,
                collateral
            );
            require(
                ledger.collateralToken.transfer(
                    caller,
                    collateral
                )
            );
            return;
        }
    }

}
