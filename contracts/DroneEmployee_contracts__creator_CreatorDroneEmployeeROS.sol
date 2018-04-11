import 'ros/DroneEmployeeROS.sol';

library CreatorDroneEmployeeROS {
    function create(address _endpoint, address _controller, address _drone) returns (DroneEmployeeROS)
    { return new DroneEmployeeROS(_endpoint, _controller, _drone); }

    function version() constant returns (string)
    { return "v0.4.0 (bab31dcb)"; }

    function interface() constant returns (string)
    { return '[{"constant":false,"inputs":[],"name":"kill","outputs":[],"type":"function"},{"constant":false,"inputs":[{"name":"_response","type":"address"}],"name":"setRoute","outputs":[],"type":"function"},{"constant":false,"inputs":[{"name":"_route_id","type":"uint32"}],"name":"flightDone","outputs":[],"type":"function"},{"constant":true,"inputs":[{"name":"","type":"uint256"}],"name":"subscribers","outputs":[{"name":"","type":"address"}],"type":"function"},{"constant":false,"inputs":[{"name":"_checkpoints","type":"address[]"}],"name":"flight","outputs":[],"type":"function"},{"constant":false,"inputs":[{"name":"_owner","type":"address"}],"name":"delegate","outputs":[],"type":"function"},{"constant":true,"inputs":[],"name":"owner","outputs":[{"name":"","type":"address"}],"type":"function"},{"constant":false,"inputs":[{"name":"_plan","type":"address"}],"name":"setFlightPlan","outputs":[],"type":"function"},{"constant":false,"inputs":[{"name":"_name","type":"string"},{"name":"_type","type":"string"}],"name":"mkPublisher","outputs":[{"name":"","type":"address"}],"type":"function"},{"constant":false,"inputs":[{"name":"_name","type":"string"},{"name":"_type","type":"string"},{"name":"_callback","type":"address"}],"name":"mkSubscriber","outputs":[{"name":"","type":"address"}],"type":"function"},{"constant":true,"inputs":[{"name":"","type":"uint256"}],"name":"publishers","outputs":[{"name":"","type":"address"}],"type":"function"},{"inputs":[{"name":"_endpoint","type":"address"},{"name":"_controller","type":"address"},{"name":"_drone","type":"address"}],"type":"constructor"}]'; }
}
