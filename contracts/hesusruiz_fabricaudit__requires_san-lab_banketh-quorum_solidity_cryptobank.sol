pragma solidity ^0.4.0;

import "paymentsProcessor";

contract cryptobank {

    // cryptobank v2.2
    // Changes:
    // - Renaming

    /* All numbers in cents of currency units */

    /* Common (global) public variables, types and constants */

    // The address that controls the bank.
    address public bank;
    // The address of the payment processor.
    address public processor;

    // The fee rate.
    uint256 public feePerMillion;
    // The maximum fee charged.
    uint256 public maxFee;

    // The name of the bank.
    bytes32 public bankName;
    // The BIC code of the bank.
    bytes32 public bankCode;
    // The currency that balances of this bank are expressed in.
    bytes32 public currency;

    // Flag to indicate the system is paused for maintenance (set by the bank)
    bool    public pausedForMaintenance;


    // Currency tags:
    bytes32 constant USD = "USD";
    bytes32 constant EUR = "EUR";
    bytes32 constant PLN = "PLN";
    bytes32 constant GBP = "GBP";
    bytes32 constant MXN = "MXN";
    bytes32 constant BRL = "BRL";
    bytes32 constant CLP = "CLP";
    bytes32 constant CHF = "CHF";
    bytes32 constant AUD = "AUD";
    bytes32 constant NZD = "NZD";
    bytes32 constant JPY = "JPY";
    bytes32 constant CAD = "CAD";

    // Internal struct representing an account in the bank.
    struct Account {
        // To check if this account is still active (we don't delete accounts).
        bool active;
        // The address that created and owns this account.
        address owner;
        // The accounts ballance. Can be negative.
        int256 balance;
        // The maximum allowed overdraft of the account.
        uint256 overdraft;
        // Whether the account is blocked.
        bool blocked;
    }

    // An array of all the accounts.
    Account[] public accounts;

    // For efficiently finding the account of a certain address.
    mapping(address => uint256) public accountByOwner;

    /* Modifiers */

    // Only the bank can perform this function.
    modifier bankOnly {
        if (msg.sender != bank)
            throw;
        _;
    }

    // Only payment processors can perform this function.
    modifier paymentsProcessorOnly {
        if (msg.sender != processor)
            throw;
        _;
    }

    // Check if the given account number corresponds to an existing account.
    modifier accountExists(uint256 account) {
        if (account >= accounts.length)
            throw;
        _;
    }

    // Only the owner of the account with given account number can perform this
    // function.
    modifier senderOnly(uint256 account) {
        if (msg.sender != accounts[account].owner)
            throw;
        _;
    }

    // Only the owner of the payment can perform this function.
    modifier paymentSenderOnly(uint256 paymentID) {
        address senderCryptobank = paymentsProcessor(processor).get_senderCryptobank(paymentID);
        if (msg.sender != cryptobank(senderCryptobank).bank())
            throw;
        _;
    }

    // Only the receiver of the payment can perform this action.
    modifier paymentReceiverOnly(uint256 paymentID) {
        address receiverCryptobank = paymentsProcessor(processor).get_receiverCryptobank(paymentID);
        if (msg.sender != cryptobank(receiverCryptobank).bank())
            throw;
        _;
    }

    // Check if the account number corresponds to an unblocked account.
    modifier notBlocked(uint256 account) {
        if (accounts[account].blocked)
            throw;
        _;
    }

    // Check that the system is not paused for maintenance by the bank.
    modifier notPaused() {
        if(pausedForMaintenance)
            throw;
        _;
    }

    /* Events */

    event ended(uint256 errorCode);
    uint256 constant SUCCESS = 0;

    /* Constructor */

    function cryptobank(bytes32 _bankCode, bytes32 _currency) {
        bank = msg.sender;
        accounts.push(Account(true, bank, 0, 0, false)); // This will be the bank's P&L account (#0)
        accounts.push(Account(true, bank, 0, 0, false)); // This will be the payments account (#1), controlled by myPaymentsProcessor
        feePerMillion = 1000;
        maxFee = 100;
        bankCode = _bankCode;
        currency = _currency;
        ended(SUCCESS);
    }

    /* ERC20 token standard functions */

    // Triggered when tokens are transferred.
    event Transfer(address indexed from, address indexed to, uint256 value);

    // Unsupported
    //
    // Triggered whenever approve(address spender, uint256 value) is called.
    event Approval(address indexed owner, address indexed spender, uint256 value);

    // Get the total token supply.
    function totalSupply() constant returns (uint256 totalSupply) {
        int256 totalAmount = 0;
        for(uint256 i = 0; i < accounts.length; i++) {
            totalAmount += accounts[i].balance;
        }
        return uint256(totalAmount);
    }

    // Get the account balance of another account with address owner.
    function balanceOf(address owner) constant returns (uint256 balance) {
        for(uint256 i = 0; i < accounts.length; i++) {
            if(owner == accounts[i].owner) {
                return uint256(accounts[i].balance);
            }
        }
        return 0;
    }

    // Send value amount of tokens to address to.
    function transfer(address to, uint256 value) returns (bool success) {
        makeTransfer(uint256(getAccountNumber(msg.sender)), value, uint256(getAccountNumber(to)), "");
        return true;
    }

    // Unsupported
    //
    // Send value amount of tokens from address from to address to.
    function transferFrom(address from, address to, uint256 value) returns (bool success) {
        return false;
    }

    // Unsupported
    //
    // Allow spender to withdraw from your account, multiple times, up to the
    // value amount. If this function is called again it overwrites the current
    // allowance with value.
    function approve(address spender, uint256 value) returns (bool success) {
        return false;
    }

    // Unsupported
    //
    // Returns the amount which spender is still allowed to withdraw from owner.
    function allowance(address owner, address spender) constant returns (uint256 remaining) {
        return 0;
    }


    /* User functions: */

    // Anyone can open an account, which will be associated to a public address
    function openAccount() notPaused returns (uint256 accountNumber) {
        int256 acct = getAccountNumber(msg.sender);
        if(acct >= 0)
            return uint256(acct);
        accounts.push(Account(true, msg.sender, 0, 0, false));
        accountNumber = accounts.length - 1;
        accountByOwner[msg.sender] = accountNumber;
        ended(SUCCESS);
        return accountNumber;
    }

    // message field for reference purposes only - although it will not have any effect in the transaction
    // itself, it will be stored in the blockchain and therefore will be available to be used as reference
    // for subsequent actions
    function makeTransfer(uint256 sender, uint256 amount, uint256 receiver, bytes32 message)
            senderOnly(sender)
            notBlocked(sender)
            notBlocked(receiver)
            accountExists(receiver)
            notPaused
            returns (bool success) {
        uint256 fees = (feePerMillion * amount) / 1000000;
        if(fees > maxFee) {
            fees = maxFee;
        }
        if(accounts[sender].balance + int256(accounts[sender].overdraft) >= int256(amount)) {
            accounts[sender].balance -= int256(amount);
            accounts[receiver].balance += int256(amount - fees);
            accounts[0].balance += int256(fees);
            Transfer(accounts[sender].owner, accounts[receiver].owner, uint256(amount));
        } else {
            throw;
        }
        ended(SUCCESS);
        return true;
    }

    function redeemFunds(uint256 sender, uint256 funds, uint256 redemptionMode,
                         bytes32 routingInfo)
            accountExists(sender)
            senderOnly(sender)
            notPaused {
        if(accounts[sender].balance + int256(accounts[sender].overdraft) >= int256(funds)) {
            accounts[sender].balance -= int256(funds);
            accounts[0].balance += int256(funds);
        } else {
            throw;
        }
        ended(SUCCESS);
    }

    // Different redemption modes to be used in redeemFunds.
    uint256 constant REDEMPTION_MODE_UNKNOWN           = 0;
    uint256 constant REDEMPTION_MODE_REFER_TO_TRANSFER = 1;
    uint256 constant REDEMPTION_MODE_ROUTE_TO_ACCOUNT  = 2;
    uint256 constant REDEMPTION_MODE_RETURN_PAYMENT    = 3;

    // Result codes for redemptions.
    uint256 constant REDEMPTION_SUCCESS                 = 0;
    uint256 constant REDEMPTION_USER_UNKNOWN_TO_BANK    = 1;
    uint256 constant REDEMPTION_BANK_ACCOUNT_NOT_FOUND  = 2;
    uint256 constant REDEMPTION_BANK_TRANSFER_FAILED    = 3;
    uint256 constant REDEMPTION_CASHOUT_LIMIT_EXCEEDED  = 4;
    uint256 constant REDEMPTION_PAYMENT_FAILED          = 5;
    uint256 constant REDEMPTION_UNKNOWN_REDEMPTION_MODE = 6;
    uint256 constant REDEMPTION_FAILED_UNSPECIFIED      = 7;


    /* Backoffice functions: */

    // Change the name of this bank.
    function setBankName(bytes32 _bankName) bankOnly {
        bankName = _bankName;
        ended(SUCCESS);
    }

    // Update the fee policy of this bank.
    function setFees(uint256 _feePerMillion, uint256 _maxFee) bankOnly {
        feePerMillion = _feePerMillion;
        maxFee = _maxFee;
        ended(SUCCESS);
    }

    // Add new funds to the given account.
    function addFunds(uint256 account, uint256 funds) bankOnly accountExists(account) {
        accounts[account].balance += int256(funds);
        ended(SUCCESS);
    }

    // Remove funds from the given account.
    function removeFunds(uint256 account, uint256 funds, uint256 redemptionHash, uint256 errorCode)
            bankOnly accountExists(account) {
        if(accounts[account].balance + int256(accounts[account].overdraft) >= int256(funds)) {
            accounts[account].balance -= int256(funds);
        } else {
            throw;
        }
        ended(SUCCESS);
    }

    // Change the overdraft allowance for the given account.
    function setOverdraft(uint256 account, uint256 limit) bankOnly accountExists(account) {
        accounts[account].overdraft = limit;
        ended(SUCCESS);
    }

    // Block the given account.
    function blockAccount(uint256 account) bankOnly accountExists(account) {
        accounts[account].blocked = true;
        ended(SUCCESS);
    }

    // Unblock the given account.
    function unblockAccount(uint256 account) bankOnly accountExists(account) {
        accounts[account].blocked = false;
        ended(SUCCESS);
    }

    function pause_for_maintenance() bankOnly {
        pausedForMaintenance = true;
        ended(SUCCESS);
    }

    function resume() bankOnly {
        pausedForMaintenance = false;
        ended(SUCCESS);
    }

    /* Payments functions */

    // Status codes
    uint256 constant STATUS_EMPTY             = 0;
    uint256 constant STATUS_SUBMITTED         = 1;
    uint256 constant STATUS_CANCELLED         = 2;
    uint256 constant STATUS_REJECTED          = 3;
    uint256 constant STATUS_RETURNED          = 4;
    uint256 constant STATUS_FINISHED          = 5;

    // Key to call this before doing anything with payments!
    function set_payments_processor(address paymentsProcessorAddress) bankOnly {
        processor = paymentsProcessorAddress;
        paymentsProcessor(processor).register();
        ended(SUCCESS);
    }

    // This will be called by the sender bank to submit a payment requested by the client. Once the payment
    // has been successfully submitted, the sending bank needs to notify the receiving cryptobank that it
    // should either accept or reject this incoming payment by calling notify_payment_acceptance_request
    // (defined below). We would love to do this from this same method call, but unfortunately internal method
    // calls among contracts do not create transactions in the ledger, so the sending bank will have to do it
    // on its own, as atomically as possible
    function submit_payment (
        uint256    paymentID,
        uint256    paymentType,
        bytes32 senderRouting,
        bytes32 senderMessage,
        uint256    baseAmount,
        address receiverCryptobank,
        bytes32 receiverRouting
    ) bankOnly notPaused {
        addFunds(1, baseAmount);
        paymentsProcessor(processor).create_payment(
            paymentID,
            paymentType,
            senderRouting,
            senderMessage,
            baseAmount,
            receiverCryptobank,
            receiverRouting
        );
        ended(SUCCESS);
    }

    // This is for the sending bank to notify directly to the receiver cryptobank that it should accept or
    // reject this payment, as explained above
    function notify_payment_acceptance_request (uint256 paymentID) paymentSenderOnly(paymentID) notPaused {
        address receiverCryptobank = paymentsProcessor(processor).get_receiverCryptobank(paymentID);
        if (bank != cryptobank(receiverCryptobank).bank())
            throw;
        ended(SUCCESS);
    }

    // This can be called by the sending bank to cancel an outstanding payment (e.g. if a timeout occurs)
    function cancel_payment(uint256 paymentID) bankOnly notPaused {
        paymentsProcessor(processor).cancel_payment(paymentID); // Will throw an exception if too late
        accounts[1].balance -= int256(paymentsProcessor(processor).get_baseAmount(paymentID));
        // accounts[1].balance -= paymentsProcessor(processor).payments[paymentID].baseAmount;
        ended(SUCCESS);
    }

    // This can be called by the receiving bank to accept and terminate a payment in the bank's systems
    // One the receiving bank checks that this has gone through, it can look up the amount owed in the
    // term currency and make the transfer from the omnibus account into the client account (so it is
    // consistent with the removeFunds we just did)
    function accept_payment (
        uint256    paymentID, // The paymentsProcessor's one!
        bytes32 receiverMessage
    )
            bankOnly
            notPaused {
        uint256 liquidityAccount;
        uint256 termAmount;
        (liquidityAccount, termAmount) = paymentsProcessor(processor).execute_payment(paymentID, receiverMessage);
        removeFunds(liquidityAccount, termAmount, 0, REDEMPTION_SUCCESS);
        ended(SUCCESS);
    }

    // This is to be called by the payments processor to ask the sending cryptobank to proceed with the payment
    function committ_payment(uint256 paymentID, uint256 to_account) paymentsProcessorOnly notPaused {
        accounts[1].balance -= int256(paymentsProcessor(processor).get_baseAmount(paymentID));
        accounts[to_account].balance += int256(paymentsProcessor(processor).get_baseAmount(paymentID));
        ended(SUCCESS);
    }

    // This can be called by the receiver bank to reject an incoming payment, specifying a reason
    // In such case, the receiving bank will have to notify the sending cryptobank that the payment
    // has been rejected, so the sending bank can return the funds to the sender client and finish
    // the payment by setting the status to PAYMENT_RETURNED. Again, we would love to do this from
    // this same method call, but unfortunately internal method calls among contracts do not create
    // transactions in the ledger, so the sending bank will have to do it on its own, as atomically as
    // possible
    function reject_payment (uint256 paymentID, bytes32 reason) bankOnly notPaused {
        paymentsProcessor(processor).reject_payment(paymentID, reason);
        ended(SUCCESS);
    }

    // This is for the sending bank to notify directly to the receiver cryptobank that it should accept or
    // reject this payment, as explained above
    function notify_payment_reject (uint256 paymentID) paymentReceiverOnly(paymentID) notPaused {
        if (paymentsProcessor(processor).get_status(paymentID) != STATUS_REJECTED)
            throw;
        address senderCryptobank = paymentsProcessor(processor).get_senderCryptobank(paymentID);
        if (bank != cryptobank(senderCryptobank).bank())
            throw;
        ended(SUCCESS);
    }

    // This is to be called by the sender bank to acknowledge a notify_payment_reject and finally close
    // the payment
    function return_rejected_payment(uint256 paymentID) paymentSenderOnly(paymentID) notPaused {
        uint256 baseAmount = paymentsProcessor(processor).get_baseAmount(paymentID);
        removeFunds(1, baseAmount, 0, REDEMPTION_PAYMENT_FAILED);
        paymentsProcessor(processor).payment_returned(paymentID);
        ended(SUCCESS);
    }

    /* Public system info functions */

    // Get the account number of the account associated with the given address.
    function getAccountNumber(address user) constant returns (int256) {
        uint256 nb = accountByOwner[user];
        if (nb == 0) {
            // account does not exist
            return -1;
        } else {
            return int256(nb);
        }
    }

    // Get the total number of accounts.
    function numberOfAccounts() constant returns (uint256) {
        return accounts.length;
    }

    /* Special functions */

    // Close the bank.
    function closeDown() bankOnly {
        selfdestruct(bank);
        ended(SUCCESS);
    }

    // Change the address of the bank.
    function changeBankAddress(address newAddress) bankOnly {
        bank = newAddress;
        ended(SUCCESS);
    }

    function () { throw; }

}
