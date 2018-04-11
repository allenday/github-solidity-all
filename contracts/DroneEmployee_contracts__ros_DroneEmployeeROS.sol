import 'interface/DroneEmployeeInterface.sol';

contract RouteReleaseHandler is MessageHandler, Mortal {
    function incomingMessage(Message _msg) onlyOwner {
        StdUInt32 route_id = StdUInt32(_msg);
        DroneEmployeeROS(owner).flightDone(route_id.data());
    }
}

contract DroneEmployeeROS is ROSCompatible, DroneEmployeeROSInterface {
    DroneEmployeeInterface drone;
    Publisher           routePub;
    RouteController     controller;
    RouteReleaseHandler releaseHandler;

    /* Initial */
    function DroneEmployeeROS(address _endpoint, address _controller, address _drone) ROSCompatible(_endpoint) {
        drone      = DroneEmployeeInterface(_drone);
        controller = RouteController(_controller);
        routePub   = mkPublisher('route', 'small_atc_msgs/RouteResponse');
        releaseHandler = new RouteReleaseHandler();
        mkSubscriber('release', 'std_msgs/UInt32', releaseHandler);
    }

    function flight(Checkpoint[] _checkpoints) {
        if (msg.sender != address(flightPlan)) throw;
        
        controller.makeRoute(_checkpoints);
    }

    function setRoute(RouteResponse _response) {
        if (msg.sender != address(controller)) throw;
        
        routePub.publish(_response);
    }

    function flightDone(uint32 _route_id) {
        if (msg.sender != address(releaseHandler)) throw; 
        
        controller.dropRoute(_route_id);
        drone.flightDone();
    }
}
