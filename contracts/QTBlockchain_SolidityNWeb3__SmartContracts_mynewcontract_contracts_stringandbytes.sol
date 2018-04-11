pragma solidity ^0.4.4;

contract stringandbytes {
  function stringandbytes() {
    // constructor
  }

  string name;
  bytes locations;

  function setName(string value) {
    name = value;
  }

  function getName() returns (string) {
    return name;
  }

  function isNameEmpty() returns (bool) {
    return (bytes(name).length == 0);
  }

}
