pragma solidity ^0.4.2;

// Unfortunately libraries can not inherit from other libraries, otherwise the IterableAddressMapping
//   and IterableAddressBalanceMapping could inherit from a shared base.

/// @dev Models an address mapping where it is possible to both iterate through the values, and quickly look up to see if a particular address is in mapping
library IterableAddressMapping {
    struct iterableAddressMap {
        mapping(address => IndexValue) data;
        address[] keys;
        uint size;
    }
    struct IndexValue { uint keyIndex; }

    function add(iterableAddressMap storage self, address mappedAddress) {
        if (self.data[mappedAddress].keyIndex == 0) {
            uint key = self.keys.push(mappedAddress);
            self.data[mappedAddress].keyIndex = key;
            self.size ++;
        }
    }

    function remove(iterableAddressMap storage self, address mappedAddress) {
        if (tx.origin != mappedAddress) {
            if (self.data[mappedAddress].keyIndex != 0) {
                delete self.keys[self.data[mappedAddress].keyIndex - 1];
                delete self.data[mappedAddress];
                self.size --;
            }
        }
    }

    function contains(iterableAddressMap storage self, address mappedAddress) returns (bool) {
        return self.data[mappedAddress].keyIndex != 0;
    }

    function iterateStart(iterableAddressMap storage self) returns (uint keyIndex) {
        return iterateNext(self, 0);
    }

    function iterateValid(iterableAddressMap storage self, uint keyIndex) returns (bool) {
        return keyIndex < self.keys.length;
    }

    function iterateNext(iterableAddressMap storage self, uint keyIndex) returns (uint r_keyIndex) {
        return keyIndex++;
    }

    function iterateGet(iterableAddressMap storage self, uint keyIndex) returns (address mappedAddress) {
        mappedAddress = self.keys[keyIndex];
    }
}

/// @dev Models address => balances mapping where it is possible to both iterate through the values, and quickly look up to see if a particular address is in mapping
library IterableAddressBalanceMapping {
    struct iterableAddressBalanceMap {
        mapping(address => IndexValue) data;
        address[] keys;
        uint size;
    }

    struct IndexValue { uint keyIndex; uint32 coinBalance; int160 dollarBalance;}

    function add(iterableAddressBalanceMap storage self, address mappedAddress, uint32 coinBalance, int160 dollarBalance) {
        if (self.data[mappedAddress].keyIndex == 0) {
            uint key = self.keys.push(mappedAddress);
            self.data[mappedAddress].keyIndex = key;
            self.data[mappedAddress].coinBalance = coinBalance;
            self.data[mappedAddress].dollarBalance = dollarBalance;
            self.size ++;
        }
    }

    function remove(iterableAddressBalanceMap storage self, address mappedAddress) {
        if (self.data[mappedAddress].keyIndex != 0) {
            delete self.keys[self.data[mappedAddress].keyIndex - 1];
            delete self.data[mappedAddress];
            self.size --;
        }
    }

    function contains(iterableAddressBalanceMap storage self, address mappedAddress) returns (bool) {
        return self.data[mappedAddress].keyIndex != 0;
    }

    function valueOf(iterableAddressBalanceMap storage self, address mappedAddress) returns (uint32 coinBalance, int160 dollarBalance) {
        coinBalance = self.data[mappedAddress].coinBalance;
        dollarBalance = self.data[mappedAddress].dollarBalance;
    }

    function valueOfCoinBalance(iterableAddressBalanceMap storage self, address mappedAddress) returns (uint32 coinBalance) {
        return self.data[mappedAddress].coinBalance;
    }

    function valueOfDollarBalance(iterableAddressBalanceMap storage self, address mappedAddress) returns (int160 dollarBalance) {
        return self.data[mappedAddress].dollarBalance;
    }

    function setCoinBalance(iterableAddressBalanceMap storage self, address mappedAddress, uint32 coinBalance) {
        self.data[mappedAddress].coinBalance = coinBalance;
    }

    function setDollarBalance(iterableAddressBalanceMap storage self, address mappedAddress, int160 dollarBalance) {
        self.data[mappedAddress].dollarBalance = dollarBalance;
    }

    function addCoinAmount(iterableAddressBalanceMap storage self, address mappedAddress, uint32 coinAmount) {
        self.data[mappedAddress].coinBalance += coinAmount;
    }

    function addDollarAmount(iterableAddressBalanceMap storage self, address mappedAddress, int160 dollarAmount) {
        self.data[mappedAddress].dollarBalance += dollarAmount;
    }

    function iterateStart(iterableAddressBalanceMap storage self) returns (uint keyIndex) {
        return iterateNext(self, 0);
    }

    function iterateValid(iterableAddressBalanceMap storage self, uint keyIndex) returns (bool) {
        return keyIndex < self.keys.length;
    }

    function iterateNext(iterableAddressBalanceMap storage self, uint keyIndex) returns (uint r_keyIndex) {
        return keyIndex++;
    }

    function iterateGet(iterableAddressBalanceMap storage self, uint keyIndex) returns (address mappedAddress) {
        mappedAddress = self.keys[keyIndex];
    }

    function length(iterableAddressBalanceMap storage self) returns (uint) {
        return self.keys.length;
    }
}
