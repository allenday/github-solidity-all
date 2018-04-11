pragma solidity ^0.4.18;

/**
 * @title Utils 
 * @dev Utilities & Common Modifiers for ERC23
 * created by IAM <DEV> (Elky Bachtiar) 
 * https://www.iamdeveloper.io
 */
contract Utils {

    // verifies that an amount is greater than zero
    modifier greaterThanZero(uint256 _amount) {
        require(_amount > 0);
        _;
    }

     // verifies that an amount is greater or equal to zero
    modifier greaterOrEqualThanZero(uint256 _amount) {
        require(_amount >= 0);
        _;
    }

    // validates an address - currently only checks that it isn't null
    modifier validAddress(address _address) {
        require(_address != 0x0 && _address != address(0) && _address != 0);
        _;
    }

    // validates multiple addresses - currently only checks that it isn't null
    modifier validAddresses(address _address, address _anotherAddress) {
        require((_address != 0x0         && _address != address(0)        && _address != 0 ) &&
                ( _anotherAddress != 0x0 && _anotherAddress != address(0) && _anotherAddress != 0)
        );
        _;
    }

    // verifies that the address is different than this contract address
    modifier notThis(address _address) {
        require(_address != address(this));
        _;
    }

    // verifies that an amount is greater than zero
    modifier greaterThanNow(uint256 _startTime) {
         require(_startTime >= now);
        _;
    }
}
