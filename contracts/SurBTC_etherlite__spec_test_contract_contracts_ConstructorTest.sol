pragma solidity ^0.4.8;

contract ConstructorTest {
	uint public uintParam;
	string public stringParam;

	function ConstructorTest(uint _uintParam, string _stringParam) {
		uintParam = _uintParam;
		stringParam = _stringParam;
	}
}
