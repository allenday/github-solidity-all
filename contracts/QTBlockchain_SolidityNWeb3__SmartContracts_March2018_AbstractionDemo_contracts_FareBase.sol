pragma solidity ^0.4.4;

contract FareBase {
  function FareBase(uint16 distance,uint16 price) public {
    // constructor
    distanceTravelled = distance;
    pricePerUnit = price;
    owner = msg.sender;
  }
  
  address public owner;

  uint16 internal distanceTravelled;

  uint16 internal pricePerUnit;

  function computeFare(uint16 distance) public returns (uint);

  function setDistanceAndPrice(uint16 distance,uint16 price) internal {
    distanceTravelled = distance;
    pricePerUnit = price;  
  }
  
}
