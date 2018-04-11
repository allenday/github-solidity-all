pragma solidity >=0.0.0;

contract c {
	uint A;
	uint B;
	function c(uint a, uint b) {
		A = a;
		B = b;
	}

	function updateStorage(uint a, uint b) {
		A = a;
		B = b;
	}

	function getStorage() returns (uint, uint) {
		return (A, B);
	}
}