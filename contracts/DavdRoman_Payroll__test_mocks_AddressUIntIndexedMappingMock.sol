pragma solidity ^0.4.11;

import '../../contracts/Libs/AddressUIntIndexedMappingLib.sol';

contract AddressUIntIndexedMappingMock {
	using AddressUIntIndexedMappingLib for AddressUIntIndexedMappingLib.Struct;

	AddressUIntIndexedMappingLib.Struct self;

	function mock_length() constant returns (uint) {
		return self.length();
	}

	function mock_getAddress(uint _index) constant returns (address) {
		return self.getAddress(_index);
	}

	function mock_getUInt(address _address) constant returns (uint) {
		return self.getUInt(_address);
	}

	function mock_contains(address _address) constant returns (bool) {
		return self.contains(_address);
	}

	function mock_set(address _address, uint _uint) {
		self.set(_address, _uint);
	}

	function mock_remove(address _address) {
		self.remove(_address);
	}

	function mock_clear() {
		self.clear();
	}
}
