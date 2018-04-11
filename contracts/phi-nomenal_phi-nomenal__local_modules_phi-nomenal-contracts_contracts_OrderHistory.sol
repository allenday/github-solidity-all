pragma solidity ^0.4.6;

import './OrderHistoryLeg.sol';
import './Location.sol';

contract OrderHistory {
    OrderHistoryLeg[] public legs;

    function amountOfLegs() constant returns (uint) {
        return legs.length;
    }

    function add(OrderHistoryLeg leg) {
        legs.push(leg);
    }

    function addDemoData() {
        Location factoryLocation = new Location(Location.LocationType.Factory, 'Shenzhen');
        Location warehouseLocation = new Location(Location.LocationType.Warehouse, 'Rotterdam');
        Location retailerLocation = new Location(Location.LocationType.Retailer, 'Groningen');
        Location consumerLocation = new Location(Location.LocationType.Consumer, 'The Big Building');

        OrderHistoryLeg leg1 = new OrderHistoryLeg(
            OrderHistoryLeg.Mode.Airplane, 11220, 4000,
            factoryLocation, warehouseLocation);
        OrderHistoryLeg leg2 = new OrderHistoryLeg(
            OrderHistoryLeg.Mode.Truck, 201, 50,
            warehouseLocation, retailerLocation);
        OrderHistoryLeg leg3 = new OrderHistoryLeg(
            OrderHistoryLeg.Mode.Bike, 5, 1,
            retailerLocation, consumerLocation);

        legs.push(leg1);
        legs.push(leg2);
        legs.push(leg3);
    }
}
