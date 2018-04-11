import './ros_interface.sol';
import './DroneEmployeeROSInterface.sol';
import 'common/Mortal.sol';

/* Flight plan contract */
contract FlightPlan is Mortal {
    /* Flight plan checkpoint list */
    Checkpoint[] public checkpoints;
    
    /* Base drone interface */
    DroneEmployeeROSInterface drone;
    
    /* Make a flight plan and store drone base contract address */
    function FlightPlan(address _drone)
    { drone = DroneEmployeeROSInterface(_drone); }

    /* Append new point into plan */
    function append(Checkpoint _checkpoint) onlyOwner
    { checkpoints[checkpoints.length++] = _checkpoint; }
    
    /* Run flight plan on drone */
    function run() onlyOwner
    { drone.flight(checkpoints); }
}

