pragma solidity ^0.4.11;

/// @title SubscriptionWallet.
contract SubscriptionWallet {

    address public subscriber;

    // Subscription status values

    // Newly registered, awaiting approval
    uint constant PENDING = 1;

    // Active
    uint constant ACTIVE = 2;

    // Terminated
    uint constant CLOSED = 3;

    struct Subscription{
        uint status;
        bytes32 name;
        uint monthlyCharge;
    }

    // The list of subscriptions the subscriber has signed up for
    mapping(address => Subscription) public subscriptions;


    // Let anyone fund the wallet to pay my subscriptions
    function fundMe() payable {}

    // Let anyone fund the wallet
    function () payable {}


    // Check the funds available in the wallet
    function getBalance() returns (uint) {
        return this.balance;
    }


    function addSubscription(address provider, bytes32 name, uint monthlyCharge){

        subscriptions[provider].name = name;
        subscriptions[provider].monthlyCharge = monthlyCharge;
        subscriptions[provider].status = PENDING;

    }

}