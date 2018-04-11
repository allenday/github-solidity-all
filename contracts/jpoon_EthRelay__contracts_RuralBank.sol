pragma solidity ^0.4.4;

import "./TransferDetails.sol";

contract RuralBank {
	mapping (string => uint) balances;
	mapping (string => uint) numTransfers;
	mapping (string => address[]) transfers;
	address[] transferApprovers;
	uint routingCode;

	event SendExternalTransfer(string _origAccount, uint _origBank, string _destAccount, uint _destBank, uint _amount);
	event AcceptExternalTransfer(string _origAccount, uint _origBank, string _destAccount, uint _destBank, uint _amount);
	event NewTransfer(address _transferAddress);

	function credit(string account, uint amount) private {
		balances[account] += amount;
	}

	function debit(string account, uint amount) private returns(bool success) {
		if (success = balances[account] >= amount)
			balances[account] -= amount;
		return success;
	}

	function RuralBank(uint _routingCode, address[] _transferApprovers) {
		routingCode = _routingCode;
		transferApprovers = _transferApprovers;
	}

	function getBalance(string account) constant returns(uint) {
		return balances[account];
	}

	function deposit(string account, uint amount) {
		credit(account, amount);
	}

	function withdraw(string account, uint amount) {
		debit(account, amount);
	}

	function getTransfer(string account, uint id) returns(address) {
		return transfers[account][id];
	}

	function initiateTransfer(string origAccount, string destAccount, uint destBank, uint amount) {
		if (debit(origAccount, amount)) {
			address transfer = new TransferDetails(origAccount, routingCode, destAccount, destBank, amount, transferApprovers);
			transfers[origAccount].push(transfer);
			NewTransfer(transfer);
		}
	}

	function executeTransfer(string origAccount, string destAccount, uint destBank, uint amount) {
		if (routingCode == destBank) {
			credit(destAccount, amount);
		} else {
			SendExternalTransfer(origAccount, routingCode, destAccount, destBank, amount);
		}
	}

	function acceptExternalTransfer(string origAccount, uint origBank, string destAccount, uint amount) {
		address[] approvers;
		approvers.push(address(this));
		TransferDetails transfer = new TransferDetails(origAccount, origBank, destAccount, routingCode, amount, approvers);
		transfer.approve();

		transfers[origAccount].push(transfer);
		AcceptExternalTransfer(origAccount, origBank, destAccount, routingCode, amount);
	}
}
