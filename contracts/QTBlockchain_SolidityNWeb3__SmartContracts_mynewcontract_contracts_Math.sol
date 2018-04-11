pragma solidity ^0.4.4;

contract Math {
  function Math(int value) {
    // constructor
    result = value;
  }

   int result;

  function getResult() returns (int) {
    return result;
  }

  function addToResult(int value) {
    result += value;
  }

  function mulToResult(int value) {
    result *= value;
  }
}
