pragma solidity ^0.4.4;
import "./FareBase.sol";
contract AutoFare is FareBase {
  function AutoFare(uint16 distance,uint16 price) FareBase(distance,price)  public {
    // constructor
  }

  function() public payable {

  }
  uint lastReceived = 0;

  function receiveEther() public payable {
      owner = msg.sender;
      lastReceived = msg.value;
  }

  function computeFare(uint16 distance) public returns (uint) {
    distanceTravelled = distance;
    var value = (distanceTravelled*pricePerUnit * 110)/100;
    return uint(value);
  }

  function  getBalance() public view returns (uint) {
    return this.balance;
  }
    
  
}
