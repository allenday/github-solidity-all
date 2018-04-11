pragma solidity ^0.4.4;

import "./Ownership.sol";
contract VehicleRTO is Ownership {
  function VehicleRTO(address rtoAddress)  Ownership() public {
    // constructor
    addRTO(0, rtoAddress);
  }

  mapping (address=>Vehicle) private registrationMap ;

  struct Vehicle {
    string registrationNumber;
    string make;
    uint8  year;
  }

  function getOwnerVehicleDetails(address owner) public view onlyOwnerOrRTO returns 
    (string registrationNo,string make,uint8 year) 
    {
    var vehicleDetails = registrationMap[owner];
    registrationNo = vehicleDetails.registrationNumber;
    make = vehicleDetails.make;
    year = vehicleDetails.year;
  }

  function registerVehicle(string registrationNo,string make,uint8 year,address owner)
    public onlyRTO 
  {
    var vehicleDetails = Vehicle(registrationNo,make,year);
    registrationMap[owner] = vehicleDetails;
    //fill the map with structure
  }
}
