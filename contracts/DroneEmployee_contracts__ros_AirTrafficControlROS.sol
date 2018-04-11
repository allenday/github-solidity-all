import 'interface/ros_interface.sol';
import 'interface/AirTrafficControllerInterface.sol';

contract ResponseListener is MessageHandler, Mortal {
    address[] public clients;

    function newRequest(address _addr) onlyOwner returns (uint32) {
        clients[clients.length++] = _addr;
        return uint32(clients.length);
    }

    function incomingMessage(Message _msg) onlyOwner {
        var response = RouteResponse(_msg);
        var aircraft = Aircraft(clients[response.id() - 1]);
        AirTrafficControllerROS(owner).setRoute(aircraft, response);
    }
}

contract AirTrafficControllerROS is ROSCompatible, RouteController, Mortal {
    Publisher                     route_request;
    Publisher                     route_remover;
    ResponseListener              listener;
    AirTrafficControllerInterface atc;

    function AirTrafficControllerROS(address _endpoint, address _atc) ROSCompatible(_endpoint) {
        atc = AirTrafficControllerInterface(_atc);

        route_request = mkPublisher('route/request',
                                    'small_atc_msgs/RouteRequest');
        route_remover = mkPublisher('route/remove', 'std_msgs/UInt32');

        listener = new ResponseListener();
        mkSubscriber('route/response',
                     'small_atc_msgs/RouteResponse',
                     listener);
    }

    function makeRoute(Checkpoint[] _checkpoints) {
        if (!atc.isPaid(msg.sender)) throw;

        uint32 id = listener.newRequest(msg.sender);
        route_request.publish(new RouteRequest(_checkpoints, id));
    }

    function dropRoute(uint32 _id) {
        if (listener.clients(_id) != msg.sender) throw;

        route_remover.publish(new StdUInt32(_id));
    }
    
    function setRoute(Aircraft _aircraft, RouteResponse _response) {
        if (msg.sender != address(listener)) throw;
        
        _aircraft.setRoute(_response);
    }
}
