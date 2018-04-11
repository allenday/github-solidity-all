pragma solidity ^0.4.3;

import './Token.sol';

contract Fund {

    address private contentAddress;

    modifier restricted() {
        if (msg.sender != contentAddress) {
            throw;
        }
        _;
    }

    function Fund() {
        contentAddress = msg.sender;
    }

    function getEtherBalance() constant returns (uint256) {
        return this.balance;
    }

    function getBalance(address token) constant returns (uint256) {
        return Token(token).balanceOf(this);
    }

    function claimEther() restricted() returns (uint256) {
        uint256 value = this.balance;
        if (value > 0 && contentAddress.send(this.balance)) {
            return value;
        }
        else {
            return 0;
        }
    }

    function claim(address token) restricted() returns (uint256) {
        uint256 value = Token(token).balanceOf(this);
        if (value > 0 && Token(token).transfer(contentAddress, value)) {
            return value;
        }
        else {
            return 0;
        }
    }

}
