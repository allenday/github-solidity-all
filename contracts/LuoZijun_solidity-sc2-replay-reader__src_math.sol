pragma solidity ^0.4.8;

library Math {
    function max(uint a, uint b) returns (uint) {
        if (a > b) return a;
        else return b;
    }
    function min(uint a, uint b) returns (uint) {
        if (a < b) return a;
        else return b;
    }
    // function floor(uint n) returns (uint) {
        
    // }
}