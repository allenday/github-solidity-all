import 'src/DroneEmployee.sol';

library CreatorDroneEmployee {
    function create(string _name, address _baseCoords, address _atc, address _market, address _credits, bool _video_streaming) returns (DroneEmployee)
    { return new DroneEmployee(_name, _baseCoords, _atc, _market, _credits, _video_streaming); }

    function version() constant returns (string)
    { return "v0.4.0 (bab31dcb)"; }

    function interface() constant returns (string)
    { return '[{"constant":true,"inputs":[],"name":"name","outputs":[{"name":"","type":"string"}],"type":"function"},{"constant":true,"inputs":[],"name":"flightPrice","outputs":[{"name":"","type":"uint256"}],"type":"function"},{"constant":true,"inputs":[],"name":"tickets","outputs":[{"name":"","type":"address"}],"type":"function"},{"constant":true,"inputs":[],"name":"credits","outputs":[{"name":"","type":"address"}],"type":"function"},{"constant":false,"inputs":[],"name":"getFlight","outputs":[{"name":"","type":"address"}],"type":"function"},{"constant":false,"inputs":[],"name":"kill","outputs":[],"type":"function"},{"constant":true,"inputs":[],"name":"base","outputs":[{"name":"","type":"address"}],"type":"function"},{"constant":false,"inputs":[{"name":"_price","type":"uint256"}],"name":"setFlightPrice","outputs":[],"type":"function"},{"constant":false,"inputs":[{"name":"_owner","type":"address"}],"name":"delegate","outputs":[],"type":"function"},{"constant":false,"inputs":[{"name":"_ros","type":"address"}],"name":"setROSInterface","outputs":[],"type":"function"},{"constant":true,"inputs":[],"name":"market","outputs":[{"name":"","type":"address"}],"type":"function"},{"constant":true,"inputs":[],"name":"owner","outputs":[{"name":"","type":"address"}],"type":"function"},{"constant":false,"inputs":[],"name":"flightDone","outputs":[],"type":"function"},{"constant":true,"inputs":[],"name":"getROSInterface","outputs":[{"name":"","type":"address"}],"type":"function"},{"inputs":[{"name":"_name","type":"string"},{"name":"_baseCoords","type":"address"},{"name":"_atc","type":"address"},{"name":"_market","type":"address"},{"name":"_credits","type":"address"}],"type":"constructor"},{"anonymous":false,"inputs":[{"indexed":true,"name":"sender","type":"address"},{"indexed":true,"name":"plan","type":"address"}],"name":"FlightPlanCreated","type":"event"}]'; }
}
