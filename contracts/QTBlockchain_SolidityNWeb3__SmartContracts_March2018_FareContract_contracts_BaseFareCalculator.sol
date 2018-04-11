pragma solidity ^0.4.4;

contract BaseFareCalculator {
  function BaseFareCalculator() {
    // constructor
  }

  string[] locations;

  function calculateFare(string source,string destination) returns (uint256);

  function AddLocation(string location) {
    locations.push(location);
  }
}
