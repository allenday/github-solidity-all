pragma solidity ^0.4.2;

import "Admin.sol";

contract Stoppable is Admin {
    bool public emergency;

    modifier stopInEmergency {
        if (emergency) throw;
        _;
    }

    function startEmergency() external onlyAdmin {
        emergency = true;
    }

    function stopEmergency() external onlyAdmin {
        emergency = false;
    }
}
