pragma solidity ^0.4.4;

contract MapDemo {
  function MapDemo() {
    // constructor
  }

  mapping (uint=>string) numberStringMap;

  function setSomeValues() {
    numberStringMap[0] = "zero";
    numberStringMap[1] = "One";
  }

  function getWord(uint number) returns (string word) {
    word = numberStringMap[number];
  }
}
