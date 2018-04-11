pragma solidity ^0.4.7;

contract Calculator {
	int public value;
	bool blocked = false;
	address admin;

	function Calculator() {
		admin = msg.sender;
	}
	modifier notBlocked() {
		if (!blocked) {
			_;
		} else {
			throw;
		}
	}

	function add(int _number) notBlocked() {
		value += _number;
	}

	function subtract(int _number) notBlocked() {
		value -= _number;
	}

    function init(int _number) notBlocked() {
		value = _number;
	}

	function result() constant notBlocked() returns (int _number) {
		_number = value;
	}

	function changeBlock(bool _block) {
		if (admin == msg.sender) {
			blocked = _block;
		}
	}
}