import './ros_interface.sol';
import 'token/Token.sol';
import 'common/Mortal.sol';

contract AirTrafficControllerInterface is Mortal {
    string   public name;
    SatFix[] public area;

    Token public token;

    /* Mapping for payment check */
    mapping(address => bool) public isPaid;

    /* Take payment from sender for `_drone` account and returns true when all is OK */
    function pay(address _drone) returns (bool);
    
    /* Release drone by address */
    function release(address _drone);
    
    /* Get ROS interface contract */
    RouteController public getROSInterface;

    function setROSInterface(RouteController _ros) onlyOwner
    { getROSInterface = _ros; }
}
