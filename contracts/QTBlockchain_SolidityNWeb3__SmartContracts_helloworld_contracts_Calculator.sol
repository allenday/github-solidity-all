/**
 * Skeleton code for Calculator
 * This contract is for demonstrating the use of Truffle framework.
 **/

pragma solidity ^0.4.4;

contract Calculator {

  // Result of the operation are always stored in this variable
  uint result=10;

  function Calculator() {
    // constructor
    
  }

  // returns the result
  function getResult() returns (uint) {
    return result;
  }

  // result = result + num
  function addToNumber(uint num) {
    result += num;
  }

  // result = result - num
  function substractNumber(uint num) {
    result -= num;
  }

  // result = result * num
  function multiplyWithNumber(uint num) {
    result *= num;
  }

  // result = result / num
  function divideByNumber(uint num) {
    result /= num;
  }

}