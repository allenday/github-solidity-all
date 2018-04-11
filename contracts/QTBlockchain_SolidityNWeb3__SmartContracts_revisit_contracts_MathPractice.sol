pragma solidity ^0.4.4;

contract MathPractice {
  function MathPractice() {
    // constructor
  }

  int result;
  
  function getResult() returns (int) {
    return result;
  }

  function addToResult(int value) {
    int temp = result+value;
    result = temp;
  }
  
}
