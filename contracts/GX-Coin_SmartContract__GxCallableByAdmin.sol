pragma solidity ^0.4.2;

import './GxUsesAdmins.sol';
import './GxAccountsInterface.sol';


// Implements "callableByAdmin" modifier
contract GxCallableByAdmin is GxUsesAdmins {
    modifier callableByAdmin {
        if (isAdmin(msg.sender)) {
            _;
        } else {
            throw;
        }
    }

    function isAdmin(address accountAddress) public constant returns (bool _i) {
        return admins.contains(accountAddress);
    }
}
