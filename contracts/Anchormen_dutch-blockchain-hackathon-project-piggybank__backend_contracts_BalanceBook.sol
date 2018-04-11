pragma solidity ^0.4.4;

contract BalanceBook{
	struct Payment{
		int encrypted_change;
		bool active;
	}

	mapping (uint => mapping (string => Payment)) private payments;
	mapping (uint => uint) public public_ns;
	mapping (uint => uint) public public_gs;
	address public owner;

	function BalanceBook() {
	    owner = msg.sender;
	}

	function addHouseHold(uint household, uint n, uint g) {
		public_ns[household] = n * n;
		public_gs[household] = g;
	}

	function removeHouseHold(uint household) {
		delete public_ns[household];
		delete public_gs[household];
	}

	function addPayment(uint household, string company, int encrypted_change, bool active) {
		Payment memory payment = Payment(encrypted_change, active);
		payments[household][company] = payment;
	}

	function togglePayment(uint household, string company) {
		payments[household][company].active = !payments[household][company].active;
	}

	function getPayment(uint household, string company) returns (int, bool) {
	    Payment payment = payments[household][company];
	    return (payment.encrypted_change, payment.active);
	} 

	function getPublicKeys(uint household) returns (uint, uint) {
		return (public_ns[household], public_gs[household]);
	}
}