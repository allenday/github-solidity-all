pragma solidity ^0.4.6;

contract Location {
    enum LocationType { Factory, Warehouse, Retailer, Consumer }

    LocationType public locationType;
    string public geolocation;

    function Location(LocationType type_, string geolocation_) {
        locationType = type_;
        geolocation = geolocation_;
    }
}
