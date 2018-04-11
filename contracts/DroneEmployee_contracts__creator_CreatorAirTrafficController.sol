import 'src/AirTrafficController.sol';

library CreatorAirTrafficController {
    function create(string _name, address[] _area, address _market, address _credits) returns (AirTrafficController)
    { return new AirTrafficController(_name, _area, _market, _credits); }

    function version() constant returns (string)
    { return "v0.4.0 (bab31dcb)"; }

    function interface() constant returns (string)
    { return '[{"constant":true,"inputs":[],"name":"name","outputs":[{"name":"","type":"string"}],"type":"function"},{"constant":false,"inputs":[{"name":"_drone","type":"address"}],"name":"pay","outputs":[{"name":"","type":"bool"}],"type":"function"},{"constant":false,"inputs":[{"name":"_drone","type":"address"}],"name":"release","outputs":[],"type":"function"},{"constant":false,"inputs":[{"name":"_price","type":"uint256"}],"name":"setRoutePrice","outputs":[],"type":"function"},{"constant":true,"inputs":[],"name":"credits","outputs":[{"name":"","type":"address"}],"type":"function"},{"constant":false,"inputs":[],"name":"kill","outputs":[],"type":"function"},{"constant":false,"inputs":[{"name":"_owner","type":"address"}],"name":"delegate","outputs":[],"type":"function"},{"constant":true,"inputs":[{"name":"","type":"uint256"}],"name":"area","outputs":[{"name":"","type":"address"}],"type":"function"},{"constant":false,"inputs":[{"name":"_ros","type":"address"}],"name":"setROSInterface","outputs":[],"type":"function"},{"constant":true,"inputs":[{"name":"","type":"address"}],"name":"isPaid","outputs":[{"name":"","type":"bool"}],"type":"function"},{"constant":true,"inputs":[],"name":"market","outputs":[{"name":"","type":"address"}],"type":"function"},{"constant":true,"inputs":[],"name":"owner","outputs":[{"name":"","type":"address"}],"type":"function"},{"constant":true,"inputs":[],"name":"getROSInterface","outputs":[{"name":"","type":"address"}],"type":"function"},{"constant":true,"inputs":[],"name":"token","outputs":[{"name":"","type":"address"}],"type":"function"},{"constant":true,"inputs":[],"name":"routePrice","outputs":[{"name":"","type":"uint256"}],"type":"function"},{"inputs":[{"name":"_name","type":"string"},{"name":"_area","type":"address[]"},{"name":"_market","type":"address"},{"name":"_credits","type":"address"}],"type":"constructor"}]'; }
}
