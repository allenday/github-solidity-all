pragma solidity ^0.4.4;

contract TupleDemo {
  function TupleDemo() {
    // constructor
  }

  string name = "QT";
  uint8 age = uint8(8);

  function getNameAndAge() returns (string nameR, uint8 ageR) {
    ageR = age;
    nameR = name;
  }
}
