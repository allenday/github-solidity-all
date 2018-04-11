pragma solidity ^0.4.4;
import "./FareBase.sol";
contract CarFare is FareBase {
  function CarFare(uint16 distance,uint16 price) FareBase(distance,price)  public {
    // constructor
  }

  function computeFare(uint16 distance) public returns (uint) {
    distanceTravelled = distance;
    var value = (distanceTravelled*pricePerUnit * 110)/100;
    return uint(value);
  }

  event bookingRecieved(uint distance, address from);


  function bookCab(uint distance) public {
    bookingRecieved(distance,msg.sender);
  }
}
