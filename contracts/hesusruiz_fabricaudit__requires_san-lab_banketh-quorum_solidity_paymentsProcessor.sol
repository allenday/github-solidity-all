pragma solidity ^0.4.0;

import "cryptobank";

contract paymentsProcessor {

    struct paymentT {
        uint256    paymentType;
        address senderCryptobank;
        bytes32 senderRouting;
        bytes32 senderMessage;
        uint256    baseAmount;
        address receiverCryptobank;
        bytes32 receiverRouting;
        bytes32 receiverMessage;
        uint256    termAmount;
        uint256    appliedRate;
        uint256    status;
        uint256    blocknumber;
    }

    mapping (uint256 => paymentT) public payments;
    uint[] public payments_array;

    // Status codes
    uint256 constant STATUS_EMPTY             = 0;
    uint256 constant STATUS_SUBMITTED         = 1;
    uint256 constant STATUS_CANCELLED         = 2;
    uint256 constant STATUS_REJECTED          = 3;
    uint256 constant STATUS_RETURNED          = 4;
    uint256 constant STATUS_FINISHED          = 5;

    function get_baseAmount(uint256 paymentID) constant returns (uint256){
        return payments[paymentID].baseAmount;
    }

    function get_termAmount(uint256 paymentID) constant returns (uint256){
        return payments[paymentID].termAmount;
    }

    function get_senderCryptobank(uint256 paymentID) constant returns (address){
        return payments[paymentID].senderCryptobank;
    }

    function get_receiverCryptobank(uint256 paymentID) constant returns (address){
        return payments[paymentID].receiverCryptobank;
    }

    function get_status(uint256 paymentID) constant returns (uint256){
        return payments[paymentID].status;
    }

    struct quoteT {
        uint256 price; // in millionths percentage points (e.g. 1450000 means 1.4500)
        uint256 liquidity; // in cents of currency units
    }

    address                                          public processor;

    mapping (address => bool)                        public registeredCryptobanks;
    address[]                                        public cryptobanks_array;

    mapping (bytes32 => address)                     public bankPartners;
    mapping (address => uint256)                        public liquidityAccounts;

    mapping (bytes32 => mapping (bytes32 => quoteT)) public quotes;

    mapping (bytes32 => bool)                        public currencies;
    bytes32[]                                        public currencies_array;

    /* Modifiers */

    modifier processorOnly {
        if (msg.sender != processor)
            throw;
        _;
    }

    modifier registeredOnly(address who) {
        if (!registeredCryptobanks[who])
            throw;
        _;
    }

    modifier paymentSenderOnly(uint256 paymentID) {
        if(msg.sender != payments[paymentID].senderCryptobank)
            throw; // Requester is not an impostor
        _;
    }

    modifier paymentReceiverOnly(uint256 paymentID) {
        if(msg.sender != payments[paymentID].receiverCryptobank)
            throw; // Requester is not an impostor
        _;
    }

    /* Events */

    event ended(uint256 errorCode);
    uint256 constant SUCCESS = 0;

    /* Constructor */

    function paymentsProcessor() {
        processor = msg.sender;
        ended(SUCCESS);
    }

    /* Bank-triggered functions */

    // Simple utility to calculate the unique ID of a payment from the sender's uniqueID and its address
    function generate_paymentID(uint256 paymentSenderID) constant returns (uint256) { // to be called by the sender bank only
        bytes32 psID = bytes32(paymentSenderID);
        bytes32 addr = bytes32(msg.sender);
        bytes memory s = new bytes(64);
        for (uint256 i=0; i<32; i++) {
            s[i] = addr[i];
            s[32+i] = psID[i];
        }
        uint256 paymentID = uint256(sha3(s));
        if(payments[paymentID].status != STATUS_EMPTY) throw; // Sorry, this ID is taken
        return paymentID;
    }

    // This function will be called by the sending cryptobank in order to initiate a payment
    function create_payment(
        uint256    paymentID,
        uint256    paymentType,
        bytes32 senderRouting,
        bytes32 senderMessage,
        uint256    baseAmount,
        address receiverCryptobank,
        bytes32 receiverRouting
    ) registeredOnly(msg.sender) registeredOnly(receiverCryptobank) {
        if(payments[paymentID].status != STATUS_EMPTY) throw; // Sorry, this ID is taken
        payments[paymentID] = paymentT(
            paymentType,
            msg.sender,
            senderRouting,
            senderMessage,
            baseAmount,
            receiverCryptobank,
            receiverRouting,
            "",
            0,
            0,
            STATUS_SUBMITTED,
            block.number
        );
        payments_array.push(paymentID);
        ended(SUCCESS);
    }

    // This function can be called by the sending cryptobank to cancel a payment
    function cancel_payment(uint256 paymentID) paymentSenderOnly(paymentID) returns (uint256) {
        if(payments[paymentID].status != STATUS_SUBMITTED) throw; // Sorry, too late
        payments[paymentID].status = STATUS_CANCELLED;
        payments[paymentID].blocknumber = block.number;
        ended(SUCCESS);
        return paymentID; // Balance will be deducted directly by cryptobank at the same time it is calling this
    }

    // This function can be called by the receiving cryptobank to accept and execute a payment.
    function execute_payment(
        uint256 paymentID,
        bytes32 receiverMessage
    ) paymentReceiverOnly(paymentID) returns(uint, uint256) { // returns the liquidity account to do the redemption from, and the termAmount
        if(payments[paymentID].status != STATUS_SUBMITTED) throw; // Payment is not being cancelled
        if (quotes[cryptobank(payments[paymentID].senderCryptobank).currency()][cryptobank(payments[paymentID].receiverCryptobank).currency()].price <= 0) throw; // We have a quote
        if (quotes[cryptobank(payments[paymentID].senderCryptobank).currency()][cryptobank(payments[paymentID].receiverCryptobank).currency()].liquidity < payments[paymentID].baseAmount) throw; // The quote is big enough
        payments[paymentID].appliedRate = quotes[cryptobank(payments[paymentID].senderCryptobank).currency()][cryptobank(payments[paymentID].receiverCryptobank).currency()].price;
        uint256 term_amount = (payments[paymentID].baseAmount * payments[paymentID].appliedRate) / 1000000;
        payments[paymentID].receiverMessage = receiverMessage;
        payments[paymentID].termAmount = term_amount;
        cryptobank(payments[paymentID].senderCryptobank).committ_payment(paymentID, liquidityAccounts[payments[paymentID].senderCryptobank]);
        payments[paymentID].status = STATUS_FINISHED;
        payments[paymentID].blocknumber = block.number;
        ended(SUCCESS);
        return (liquidityAccounts[payments[paymentID].receiverCryptobank], term_amount);
    }

    // This function can be called by the receiving cryptobank to reject
    function reject_payment(
        uint256 paymentID,
        bytes32 reason
    ) paymentReceiverOnly(paymentID) {
        if(payments[paymentID].status != STATUS_SUBMITTED) throw; // Sorry, too late
        payments[paymentID].status = STATUS_REJECTED;
        payments[paymentID].blocknumber = block.number;
        payments[paymentID].receiverMessage = reason;
        ended(SUCCESS);
    }

    // This function is called by the sending cryptobank to state that the funds have been returned after
    // the receiving cryptobank rejected the payment with a reason.
    function payment_returned(uint256 paymentID) paymentSenderOnly(paymentID) {
        if(payments[paymentID].status != STATUS_REJECTED) throw;
        payments[paymentID].status = STATUS_RETURNED;
        payments[paymentID].blocknumber = block.number;
        ended(SUCCESS);
    }

    /* Trading */

    // This has to be called by the cryptobank before starting to operate with the payments processor
    function register() {
        if (!registeredCryptobanks[msg.sender]) {
            registeredCryptobanks[msg.sender] = true;
            cryptobanks_array.push(msg.sender);
            liquidityAccounts[msg.sender] = cryptobank(msg.sender).openAccount();
        }
        bankPartners[cryptobank(msg.sender).bankCode()] = msg.sender;
        if (!currencies[cryptobank(msg.sender).currency()]) {
            currencies[cryptobank(msg.sender).currency()] = true;
            currencies_array.push(cryptobank(msg.sender).currency());
        }
        ended(SUCCESS);
    }

    function many_cryptobanks() constant returns (uint256) {
        return cryptobanks_array.length;
    }

    function many_currencies() constant returns (uint256) {
        return currencies_array.length;
    }

    function many_payments() constant returns (uint256) {
        return payments_array.length;
    }

    function get_bank_data(address bank) constant returns (bytes32, bytes32, bytes32) {
        return (cryptobank(bank).bankName(), cryptobank(bank).bankCode(), cryptobank(bank).currency());
    }

    function get_liquidity_account(address bank) constant returns (bool, address, int, uint, bool) {
        return cryptobank(bank).accounts(liquidityAccounts[bank]);
    }

    // This will be called by the processor to make transfers from its cryptobank account, should it need to do so
    function make_transfer(address cryptobankAddress, uint256 amount, uint256 receiver_account, bytes32 message) processorOnly {
        cryptobank(cryptobankAddress).makeTransfer(liquidityAccounts[cryptobankAddress], amount, receiver_account, message);
        ended(SUCCESS);
    }

    // This will be called by the processor to redeem funds from its cryptobank account
    function redeem_funds(address cryptobankAddress, uint256 funds, uint256 redemption_mode, bytes32 routing_info) processorOnly {
        cryptobank(cryptobankAddress).redeemFunds(liquidityAccounts[cryptobankAddress], funds, redemption_mode, routing_info);
        ended(SUCCESS);
    }

    // This will be called by the processor to post quotes on the book
    function add_quote(
        bytes32 base_currency,
        bytes32 term_currency,
        uint256 price,
        uint256 liquidity
    ) processorOnly {
        quotes[base_currency][term_currency].price = price;
        quotes[base_currency][term_currency].liquidity = liquidity;
        ended(SUCCESS);
    }

    // Same as above, to remove quotes from the book
    function remove_quote(
        bytes32 base_currency,
        bytes32 term_currency
    ) processorOnly {
        delete quotes[base_currency][term_currency];
        // Or whatever this is done
        // If impossible, set prices to zero and check in trade methods
        ended(SUCCESS);
    }

    /* Special functions */

    function close_down() processorOnly {
        selfdestruct(processor);
        ended(SUCCESS);
    }

    function () { throw; }

}
