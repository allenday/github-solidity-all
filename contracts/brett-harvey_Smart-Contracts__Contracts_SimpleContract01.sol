pragma solidity ^0.4.11;

// Brett Harvey - 29/09/17
// This contract uses simple get and set functions to manipulate the value
// of the myValue variable. The value is initialized to 5.

contract SimpleContract01 {
    uint256 myResult = 5;

    // A simple function that adds two values together
    function Addition(uint x, uint y) {
        myResult = x + y;
    }

    // A simple function that subtracts x - y
    function Subtraction(uint x, uint y) {
        myResult = x - y;
    }

    // A simple function that multiplies x * y
    function Multiply(uint x, uint y) {
        myResult = x * y;
    }

    // A simple function that divides x / y
    function Divide(uint x, uint y) {
        myResult = x / y;
    }

    // Gets the value for myResult
    function getResult() constant returns (uint) {
        return myResult;
    }
}
