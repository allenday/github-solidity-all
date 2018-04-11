pragma solidity ^0.4.4;

contract CarRoute {
  function CarRoute(string  location) {
    // constructor
    currentLocation = location;
  }

  string[] routes;
  string currentLocation;


  function dropTo(string destination) {
    currentLocation = destination;
  }

  function getCurrentLocation() returns (string) {
    return  currentLocation;
  }



}
