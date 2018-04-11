import './FlightPlan.sol';
import 'common/Mortal.sol';
import 'token/Token.sol';

/* Base drone contract */
contract DroneEmployeeInterface is Mortal {
    /* Drone name */
    string public name;

    /* Drone base coords */
    SatFix public base;

    /* Drone employee tickets token */
    Token public tickets;

    function getFlight() returns (FlightPlan);

    /* Get ROS interface contract */
    DroneEmployeeROSInterface public getROSInterface;

    function setROSInterface(DroneEmployeeROSInterface _ros) onlyOwner
    { getROSInterface = _ros; }
    
    /* Done the flight, used by ROS interface */
    function flightDone() {
        if (msg.sender != address(getROSInterface)) throw;
    }
}
