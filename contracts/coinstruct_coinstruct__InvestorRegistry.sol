pragma solidity ^0.4.4;

import "./AddressRegistry.sol";


contract InvestorRegistry is AddressRegistry {

    address public owner;
    mapping (address => bool) public isRegistered;

    function InvestorRegistry() {
        owner = msg.sender;
    }

    function register(address _user) {
        if (msg.sender != owner) {
            throw;
        }
        isRegistered[_user] = true;
        Registered(_user);
    }

    function deregister(address _user) {
        if (msg.sender != owner) {
            throw;
        }
        delete isRegistered[_user];
    }
}
