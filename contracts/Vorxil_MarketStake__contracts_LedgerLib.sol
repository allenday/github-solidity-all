pragma solidity ^0.4.11;

import "./Ledger.sol";

/**
 * LedgerLib - Library interface to Ledger
 */
library LedgerLib {
    
    function deposit(address ledger, uint amount) public {
        Ledger(ledger).addPending(msg.sender, amount);
    }
    
    function withdraw(address ledger) public {
        uint amount = Ledger(ledger).pending(msg.sender);
        if (amount > 0) {
            Ledger(ledger).removePending(msg.sender, amount);
            msg.sender.transfer(amount);
        }
    }
}