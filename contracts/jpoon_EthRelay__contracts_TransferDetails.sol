pragma solidity ^0.4.4;

import "./RuralBank.sol";

contract TransferDetails {
    enum States { PendingApproval, Rejected, ExternalFail, Transferring, Completed }
    States state;
    string origAccount;
    uint origBank;
    string destAccount;
    uint destBank;
    uint amount;
    address bank;
    mapping (address => bool) approvers;
    mapping (address => bool) approved;
    uint numApprovers;
    uint numApproved;

	event ApprovedTransfer(address _transferAddress);
	event RejectedTransfer(address _transferAddress);
    event ExternalFailed(address _transferAddress);

    function TransferDetails(string _origAccount, uint _origBank, string _destAccount, uint _destBank, uint _amount, address[] _approvers) {
        numApproved = 0;
        numApprovers = 1; // for testing
        bank = msg.sender;

        state = States.PendingApproval;
        origAccount = _origAccount;
        origBank = _origBank;
        destAccount = _destAccount;
        destBank = _destBank;
        amount = _amount;

        for (uint i = 0; i < _approvers.length; i++) {
            approvers[_approvers[i]] = true;
        }
    }

    function getState() constant returns (uint) {
        return uint(state);
    }

    function approve() {
        if (state == States.PendingApproval) {
            if (approvers[msg.sender]) {
                if (!approved[msg.sender]) {
                    numApproved += 1;
                    approved[msg.sender] = true;
                }
            }
            if (numApproved >= numApprovers) {
                state = origBank == destBank ? States.Completed : States.Transferring;
                RuralBank ruralBank = RuralBank(bank);
                ruralBank.executeTransfer(origAccount, destAccount, destBank, amount);

                ApprovedTransfer(address(this));
            }
        }
    }

    function reject() {
        if (state == States.PendingApproval) {
            state = States.Rejected;
            RuralBank ruralBank = RuralBank(bank);
            ruralBank.deposit(origAccount, amount);
            RejectedTransfer(address(this));
        }
    }

    function externalFailure() {
        if (state == States.Transferring || state == States.PendingApproval) {
            state = States.ExternalFail;
            RuralBank ruralBank = RuralBank(bank);
            ruralBank.deposit(origAccount, amount);
            ExternalFailed(address(this));
        }
    }
}