pragma solidity ^0.4.11;

library AddressUIntIndexedMappingLib {
	struct Struct {
		address[] _index;
		mapping (address => bool) _setKeys;
		mapping (address => uint) _mapping;
	}

	function length(Struct storage self) constant returns (uint) {
		return self._index.length;
	}

	function getAddress(Struct storage self, uint _index) constant returns (address) {
		if (_index >= self._index.length) {
			return address(0);
		}

		return self._index[_index];
	}

	function getUInt(Struct storage self, address _address) constant returns (uint) {
		return self._mapping[_address];
	}

	function contains(Struct storage self, address _address) constant returns (bool) {
		return self._setKeys[_address];
	}

	function set(Struct storage self, address _address, uint _uint) {
		if (_uint == 0) {
			remove(self, _address);
		} else {
			if (!contains(self, _address)) {
				self._index.push(_address);
				self._setKeys[_address] = true;
			}
			self._mapping[_address] = _uint;
		}
	}

	function remove(Struct storage self, address _address) {
		if (!contains(self, _address)) {
			return;
		}

		removeAddress(self._index, _address);
		delete self._setKeys[_address];
		delete self._mapping[_address];
	}

	function removeAddress(address[] storage _array, address _address) private {
		for (uint i = 0; i < _array.length; i++) {
			if (_array[i] == _address) {
				removeAddressAtIndex(_array, i);
				break;
			}
		}
	}

	function removeAddressAtIndex(address[] storage _array, uint _index) private {
		if (_index >= _array.length) return;

		_array[_index] = _array[_array.length - 1];
		delete _array[_array.length - 1];
		_array.length--;
	}

	function clear(Struct storage self) {
		for (uint i; i < self._index.length; i++) {
			address addr = self._index[i];
			delete self._mapping[addr];
			delete self._setKeys[addr];
		}
		delete self._index;
	}
}
