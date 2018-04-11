import './FlightPlan.sol';
import './ros_interface.sol';
import 'common/Mortal.sol';

/* ROS part of DroneEmployee */
contract DroneEmployeeROSInterface is Aircraft, Mortal {
    /* Current flight plan contract */
    FlightPlan flightPlan;

    /* Set current flight plan */
    function setFlightPlan(FlightPlan _plan) onlyOwner
    { flightPlan = _plan; }

    /* Flight to flight plan points */
    function flight(Checkpoint[] _checkpoints) {
        if (msg.sender != address(flightPlan)) throw;
    }
}
