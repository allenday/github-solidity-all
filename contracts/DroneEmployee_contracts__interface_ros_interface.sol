import 'dapp/ROS.sol';

/*** Aircraft interface ***/
contract Aircraft {
    function setRoute(RouteResponse route);
}

/*** Route controller interface ***/
contract RouteController {
    function makeRoute(Checkpoint[] _checkpoints);
    function dropRoute(uint32 id);
}

/*** Common messages ***/
contract SatFix is Message {
    int256 public latitude;
    int256 public longitude;
    int256 public altitude;
    
    function SatFix(int256 _latitude, int256 _longitude, int256 _altitude) {
        latitude = _latitude;
        longitude = _longitude;
        altitude = _altitude;
    }
}

contract Checkpoint is Message {
    SatFix public position;
    uint32 public azimuth;
    uint32 public duration;
    
    function Checkpoint(SatFix _position, uint32 _azimuth, uint32 _duration) {
        position = _position;
        azimuth  = _azimuth;
        duration = _duration;
    }
}

contract RouteRequest is Message {
    Checkpoint[] public checkpoints;
    uint32 public id;
    
    function RouteRequest(Checkpoint[] _checkpoints, uint32 _id) {
        checkpoints = _checkpoints;
        id = _id;
    }
}

contract RouteResponse is Message {
    bool public valid;
    uint32 public id;
    SatFix[] public route;
    
    function RouteResponse(bool _valid, uint32 _id, SatFix[] _route) {
        valid = _valid;
        id = _id;
        route = _route;
    }
}

contract StdUInt32 is Message {
    uint32 public data;
    
    function StdUInt32(uint32 _data) {
        data = _data;
    }
}

contract StdInt64 is Message {
    int64 public data;

    function StdInt64(int64 _data) {
        data = _data;
    }
}
