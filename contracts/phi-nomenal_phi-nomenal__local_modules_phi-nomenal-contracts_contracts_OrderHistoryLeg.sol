pragma solidity ^0.4.6;

import './Location.sol';

contract OrderHistoryLeg {
    enum Mode { Airplane, Boat, Truck, Bike }

    Mode public mode;
    uint public distance;
    uint public co2emission;
    Location public from;
    Location public to;

    function OrderHistoryLeg(
        Mode mode_, uint distance_, uint co2emission_,
        Location from_, Location to_) {
        mode = mode_;
        distance = distance_;
        co2emission = co2emission_;
        from = from_;
        to = to_;
    }
}
