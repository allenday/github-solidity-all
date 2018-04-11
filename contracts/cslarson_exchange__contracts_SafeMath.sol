pragma solidity ^0.4.11;

contract SafeMath {

    function safeMul(uint a, uint b) constant internal returns (uint) {
        uint c = a * b;
        require(a == 0 || c / a == b);
        return c;
    }

    function safeSub(uint a, uint b) constant internal returns (uint) {
        require(b <= a);
        return a - b;
    }

    function safeAdd(uint a, uint b) constant internal returns (uint) {
        uint c = a + b;
        require(c >= a && c >= b);
        return c;
    }

    function safeDiv(uint a, uint b) constant internal returns (uint) {
        require(b > 0);
        uint c = a / b;
        require(a == b * c + a % b);
        return c;
    }
}
