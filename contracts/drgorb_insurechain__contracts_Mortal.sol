pragma solidity ^0.4.4;

import "./Owned.sol";

contract mortal is owned {
    enum Status {Requested, Accepted, Rejected, Terminated}

    function kill() {
        if (msg.sender == owner) selfdestruct(owner);
    }
}

