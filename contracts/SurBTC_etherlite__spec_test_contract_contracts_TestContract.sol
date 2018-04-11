pragma solidity ^0.4.8;

contract TestContract {
	event TestEvent(
		int indexed intParam,
		uint uintParam,
		string stringParam,
		address indexed addressParam
	);

	event TestEvent1(string indexed param);
	event TestEvent2(string indexed param);

	event TestAddressEvent(address indexed addressParam);

	function testString(string _return) constant returns (string result) {
		return _return;
	}

	function testUint(uint _return) constant returns (uint result) {
		return _return;
	}

	function testInt(int _return) constant returns (int result) {
		return _return;
	}

	function testAddress(address _return) constant returns (address result) {
		return _return;
	}

	function testIntFixedArray(int[3] _array) constant returns (int[3] result) {
		return _array;
	}

	function testIntDynArray(int[] _array) constant returns (int[] result) {
		return _array;
	}

	function testEvent(int _intParam, uint _uintParam, string _stringParam) {
		TestEvent(_intParam, _uintParam, _stringParam, msg.sender);
	}

	function testEvents() {
		TestEvent1('foo');
		TestEvent2('bar');
	}
}
