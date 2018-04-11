pragma solidity ^0.4.11;

import "./zeppelin/ownership/Ownable.sol";
import "./zeppelin/token/BasicToken.sol";

/// @title Base support for multiply access to contract.
contract MultiAccess is Ownable {

    // EVENTS

    event AccessGranted(address indexed to, bool access);

    // PUBLIC FUNCTIONS

    /// @dev Grants access to specified address.
    /// @param _to Address for which access should be changed.
    /// @param _access Address receives access when true and loses when false.
    function grantAccess(address _to, bool _access) onlyOwner {
        require(_to != address(0));
        accessGrants[_to] = _access;
        AccessGranted(_to, _access);
    }

    // MODIFIERS

    modifier accessGranted() {
        require(msg.sender == owner || accessGrants[msg.sender]);
        _;
    }

    // FIELDS

    // Set of addresses that can have access to manage the contract
    mapping(address => bool) public accessGrants;
}
