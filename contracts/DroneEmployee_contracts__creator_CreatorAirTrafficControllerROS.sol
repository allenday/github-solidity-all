import 'ros/AirTrafficControlROS.sol';

library CreatorAirTrafficControllerROS {
    function create(address _endpoint, address _atc) returns (AirTrafficControllerROS)
    { return new AirTrafficControllerROS(_endpoint, _atc); }

    function version() constant returns (string)
    { return "v0.4.0 (bab31dcb)"; }

    function interface() constant returns (string)
    { return '[{"constant":false,"inputs":[{"name":"_aircraft","type":"address"},{"name":"_response","type":"address"}],"name":"setRoute","outputs":[],"type":"function"},{"constant":false,"inputs":[],"name":"kill","outputs":[],"type":"function"},{"constant":true,"inputs":[{"name":"","type":"uint256"}],"name":"subscribers","outputs":[{"name":"","type":"address"}],"type":"function"},{"constant":false,"inputs":[{"name":"_owner","type":"address"}],"name":"delegate","outputs":[],"type":"function"},{"constant":true,"inputs":[],"name":"owner","outputs":[{"name":"","type":"address"}],"type":"function"},{"constant":false,"inputs":[{"name":"_id","type":"uint32"}],"name":"dropRoute","outputs":[],"type":"function"},{"constant":false,"inputs":[{"name":"_name","type":"string"},{"name":"_type","type":"string"}],"name":"mkPublisher","outputs":[{"name":"","type":"address"}],"type":"function"},{"constant":false,"inputs":[{"name":"_checkpoints","type":"address[]"}],"name":"makeRoute","outputs":[],"type":"function"},{"constant":false,"inputs":[{"name":"_name","type":"string"},{"name":"_type","type":"string"},{"name":"_callback","type":"address"}],"name":"mkSubscriber","outputs":[{"name":"","type":"address"}],"type":"function"},{"constant":true,"inputs":[{"name":"","type":"uint256"}],"name":"publishers","outputs":[{"name":"","type":"address"}],"type":"function"},{"inputs":[{"name":"_endpoint","type":"address"},{"name":"_atc","type":"address"}],"type":"constructor"}]'; }
}
