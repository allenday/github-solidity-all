pragma solidity ^0.4.4;

import 'zeppelin/SafeMath.sol';

contract EthSplit is SafeMath {
    address[] private shareholders;

    address private donation;

    function EthSplit(address[] shareholdersList, address donateTo) {
        shareholders = shareholdersList;
        donation = donateTo;
    }

    function payout() returns (bool result) {
        uint balance = this.balance;

        if (0 == balance) {
            return false;
        }

        uint donationValue = safeDiv(this.balance, 1000);

        if (donation != 0x0 && donation.send(donationValue)) {
            balance -= donationValue;
        }

        uint value = safeDiv(balance, shareholders.length);

        for (uint i = 0; i < shareholders.length; i++) {
            if (!shareholders[i].send(value)) {
                throw;
            }
        }

        return true;
    }

    function() payable {
        // nothing :)
    }
}
